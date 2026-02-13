import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const migrateAllUserCategoriesFromTemplate = onRequest({ timeoutSeconds: 540, memory: "1GiB" }, async (req, res) => {
    const secret = req.query.secret;

    if (secret !== "c4sh1fy-s3cr3t-985631") {
        res.status(403).send("No autorizado");
        return;
    }

    const db = admin.firestore();
    const migrationMap: { [key: string]: string } = {
        "CATS": "PETS",
        "DRUGSTORE": "HEALTH",
        "EXTRA_PAYMENT": "EXTRA_PAYMENTS",
        "PAYMENT": "PAYMENTS"
    };

    try {
        const templateSnapshot = await db.collection("app_defaults")
            .doc("categories_v1")
            .collection("items")
            .get();

        if (templateSnapshot.empty) {
            res.status(404).send("❌ No se encontró la plantilla en app_defaults");
            return;
        }

        const latestCategories = templateSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        const usersSnapshot = await db.collection("users").get();
        let totalUsers = 0;
        let totalMovementsUpdated = 0;

        for (const userDoc of usersSnapshot.docs) {
            const uid = userDoc.id;
            const batch = db.batch();
            const userCatsRef = db.collection("users").doc(uid).collection("categories");
            const currentUserCats = await userCatsRef.get();

            currentUserCats.forEach(doc => batch.delete(doc.ref));
            latestCategories.forEach(cat => {
                const { id, ...data } = cat;
                batch.set(userCatsRef.doc(id), data);
            });

            const periodsSnapshot = await db.collection("users").doc(uid).collection("billing_periods").get();

            for (const periodDoc of periodsSnapshot.docs) {
                const movementsRef = periodDoc.ref.collection("movements");

                for (const [oldId, newId] of Object.entries(migrationMap)) {
                    const movementsSnapshot = await movementsRef.where("categoryId", "==", oldId).get();

                    movementsSnapshot.forEach(movDoc => {
                        batch.update(movDoc.ref, { categoryId: newId });
                        totalMovementsUpdated++;
                    });
                }
            }

            await batch.commit();

            totalUsers++;
            console.log(`✅ Usuario ${uid} y sus periodos migrados.`);
        }

        res.status(200).send({
            status: "success",
            usersProcessed: totalUsers,
            movementsUpdated: totalMovementsUpdated,
        });

    } catch (error) {
        console.error("Error en migración masiva:", error);
        res.status(500).send("❌ Error interno en el servidor");
    }
});