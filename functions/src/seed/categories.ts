import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const migrateAllUserCategoriesFromTemplate = onRequest({ timeoutSeconds: 540, memory: "1GiB" }, async (req, res) => {
    const secret = req.query.secret;

    if (secret !== "c4sh1fy-s3cr3t-985631") {
        res.status(403).send("No autorizado");
        return;
    }

    const db = admin.firestore();
    const oldIdToName: { [key: string]: string } = {
        "PETS": "Mascotas",
        "HEALTH": "Salud",
        "HOME": "Hogar",
        "MARKET": "Supermercado",
        "PERSONAL": "Gastos personales",
        "SUBSCRIPTIONS": "Subscripciones",
        "TRANSPORT": "Transporte",
        "MISC": "Otros",
        "PAYMENTS": "Ingresos",
        "EXTRA_MISC": "Gastos Hormiga",
        "EXTRA_PAYMENTS": "Ingresos extras",
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

        const nameToNewId: { [name: string]: string } = {};
        templateSnapshot.docs.forEach(doc => {
            const name = doc.data().name as string;
            nameToNewId[name] = doc.id;
        });

        const oldIdToNewId: { [oldId: string]: string } = {};
        for (const [oldId, name] of Object.entries(oldIdToName)) {
            const newId = nameToNewId[name];
            if (newId) {
                oldIdToNewId[oldId] = newId;
            } else {
                console.warn(`⚠️ No se encontró nuevo ID para la categoría "${name}" (oldId: ${oldId})`);
            }
        }

        console.log("Mapa de IDs:", JSON.stringify(oldIdToNewId, null, 2));

        const templateCategories = templateSnapshot.docs.map(doc => ({
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
            templateCategories.forEach(cat => {
                const { id, createdAt: _createdAt, updatedAt: _updatedAt, ...data } = cat;
                batch.set(userCatsRef.doc(id), {
                    ...data,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
            });

            const periodsSnapshot = await db.collection("users").doc(uid).collection("billing_periods").get();

            for (const periodDoc of periodsSnapshot.docs) {
                const movementsRef = periodDoc.ref.collection("movements");

                for (const [oldId, newId] of Object.entries(oldIdToNewId)) {
                    const movementsSnapshot = await movementsRef.where("categoryId", "==", oldId).get();

                    movementsSnapshot.forEach(movDoc => {
                        batch.update(movDoc.ref, { categoryId: newId });
                        totalMovementsUpdated++;
                    });
                }
            }

            await batch.commit();

            totalUsers++;
            console.log(`✅ Usuario ${uid} migrado.`);
        }

        res.status(200).send({
            status: "success",
            usersProcessed: totalUsers,
            movementsUpdated: totalMovementsUpdated,
            idMap: oldIdToNewId,
        });

    } catch (error) {
        console.error("Error en migración masiva:", error);
        res.status(500).send("❌ Error interno en el servidor");
    }
});