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
        const usersSnapshot = await db.collection("users").get();

        for (const userDoc of usersSnapshot.docs) {
            const userId = userDoc.id;
            let batch = db.batch();
            let batchCount = 0;

            const orphanedGroups: { [groupKey: string]: admin.firestore.QueryDocumentSnapshot[] } = {};

            const periodsSnapshot = await db.collection("users").doc(userId).collection("billing_periods").get();

            for (const periodDoc of periodsSnapshot.docs) {
                const movementsSnapshot = await periodDoc.ref.collection("movements").get();

                movementsSnapshot.docs.forEach(doc => {
                    const data = doc.data();
                    const freqId = data.frequentId;
                    const totalIns = data.totalInstallments;

                    if ((!freqId || freqId === "") && totalIns > 1) {
                        const key = `${data.description}|${data.source}`;
                        if (!orphanedGroups[key]) {
                            orphanedGroups[key] = [];
                        }
                        orphanedGroups[key].push(doc);
                    }
                });
            }

            for (const [, docs] of Object.entries(orphanedGroups)) {
                if (docs.length === 0) continue;

                const firstData = docs[0].data();
                let maxTotal = 1;
                docs.forEach(d => {
                    const t = d.data().totalInstallments;
                    if (t && t > maxTotal) maxTotal = t;
                });

                const freqRef = db.collection("users").doc(userId).collection("frequent").doc();
                const frequentId = freqRef.id;

                batch.set(freqRef, {
                    categoryId: firstData.categoryId,
                    description: firstData.description,
                    source: firstData.source,
                    amount: firstData.amount,
                    frequency: 1,
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
