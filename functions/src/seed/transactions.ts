import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const migrateTransactionsFrequentId = onRequest({ timeoutSeconds: 540, memory: "1GiB" }, async (req, res) => {
    const secret = req.query.secret;

    if (secret !== "c4sh1fy-s3cr3t-985631") {
        res.status(403).send("No autorizado");
        return;
    }

    const db = admin.firestore();

    try {
        const movementsSnapshot = await db.collectionGroup("movements").get();
        let totalTransactionsUpdated = 0;

        let batch = db.batch();
        let batchCount = 0;

        for (const movDoc of movementsSnapshot.docs) {
            const data = movDoc.data();

            /* Si el atributo frequentId no está definido, lo inicializamos en null */
            if (data.frequentId === undefined) {
                batch.update(movDoc.ref, { frequentId: null });
                batchCount++;
                totalTransactionsUpdated++;

                /* Firestore limita los batches a 500 operaciones */
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

        console.log(`🎉 Migración finalizada.`);
        res.status(200).send({
            status: "success",
            transactionsUpdated: totalTransactionsUpdated,
        });

    } catch (error) {
        console.error("Error en migración de frequentId en transacciones:", error);
        res.status(500).send("❌ Error interno en el servidor");
    }
});
