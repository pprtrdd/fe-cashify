import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const migrateInstallments = onRequest({ timeoutSeconds: 540, memory: "1GiB" }, async (req, res) => {
    const secret = req.query.secret;

    if (secret !== "c4sh1fy-s3cr3t-985631") {
        res.status(403).send("No autorizado");
        return;
    }

    const db = admin.firestore();
    let totalGroupsCreated = 0;
    let totalMovementsUpdated = 0;
    let totalMovementsDeleted = 0;

    try {
        console.log("Starting global installment migration...");

        /* 1. Fetch ALL movements that might be orphaned installments */
        /* We look for movements where totalInstallments > 1 and frequentId is missing/empty */
        const movementsSnapshot = await db.collectionGroup("movements")
            .where("totalInstallments", ">", 1)
            .get();

        if (movementsSnapshot.empty) {
            res.status(200).send({
                status: "success",
                message: "No movements found needing migration.",
            });
            return;
        }

        /* Group docs by userId and then by "description|source" */
        /* Map structure: userId -> (description|source) -> List of docs */
        const userOrphanedGroups: { [userId: string]: { [groupKey: string]: admin.firestore.QueryDocumentSnapshot[] } } = {};

        movementsSnapshot.docs.forEach(doc => {
            const data = doc.data();
            const freqId = data.frequentId;

            /* Skip if already linked to a frequent transaction */
            if (freqId && freqId !== "") return;

            /* Find userId from path: users/{userId}/billing_periods/{periodId}/movements/{docId} */
            const pathSegments = doc.ref.path.split("/");
            const userId = pathSegments[1];

            if (!userOrphanedGroups[userId]) {
                userOrphanedGroups[userId] = {};
            }

            const key = `${data.description}|${data.source}`;
            if (!userOrphanedGroups[userId][key]) {
                userOrphanedGroups[userId][key] = [];
            }
            userOrphanedGroups[userId][key].push(doc);
        });

        for (const [userId, groups] of Object.entries(userOrphanedGroups)) {
            let batch = db.batch();
            let batchCount = 0;

            for (const [, docs] of Object.entries(groups)) {
                if (docs.length === 0) continue;

                const firstData = docs[0].data();
                let maxTotal = 1;
                docs.forEach(d => {
                    const t = d.data().totalInstallments;
                    if (t && t > maxTotal) maxTotal = t;
                });

                /* Create a new FrequentTransaction doc */
                const freqRef = db.collection("users").doc(userId).collection("frequent").doc();
                const frequentId = freqRef.id;

                batch.set(freqRef, {
                    categoryId: firstData.categoryId,
                    description: firstData.description,
                    source: firstData.source,
                    amount: firstData.amount,
                    frequency: 1, /* Monthly default */
                    totalInstallments: maxTotal,
                    isArchived: false,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                batchCount++;
                totalGroupsCreated++;

                for (const d of docs) {
                    const dData = d.data();
                    const isCompleted = dData.isCompleted ?? false;

                    if (isCompleted) {
                        batch.update(d.ref, { frequentId: frequentId });
                        totalMovementsUpdated++;
                    } else {
                        batch.delete(d.ref);
                        totalMovementsDeleted++;
                    }
                    batchCount++;

                    if (batchCount >= 450) {
                        await batch.commit();
                        batch = db.batch();
                        batchCount = 0;
                    }
                }
            }

            if (batchCount > 0) {
                await batch.commit();
            }
            console.log(`✅ User ${userId} processed.`);
        }

        res.status(200).send({
            status: "success",
            groupsCreated: totalGroupsCreated,
            movementsUpdated: totalMovementsUpdated,
            movementsDeleted: totalMovementsDeleted,
        });

    } catch (error) {
        console.error("Error in installment migration:", error);
        res.status(500).send("❌ Error interno en el servidor");
    }
});
