import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const seedDefaultConfig = onRequest(async (req, res) => {
    const secret = req.query.secret;

    if (secret !== "c4sh1fy-s3cr3t-985631") {
        res.status(403).send("No autorizado");
        return;
    }

    const db = admin.firestore();
    const appDefaultsRef = db.collection("app_defaults").doc("config_v1");
    const configCollectionRef = appDefaultsRef.collection("config");
    const settingsDocRef = configCollectionRef.doc("settings");

    const billingData = {
        billing: {
            billingPeriodType: "custom_range",
            endDay: 23,
            periodType: "custom_range",
            startDay: 24
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    try {
        const batch = db.batch();

        /* Clean */
        const currentDocs = await configCollectionRef.get();

        currentDocs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        /* Set parent */
        batch.set(appDefaultsRef, {
            version: 1,
            description: "Contenedor de configuración inicial de usuario",
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });

        /* Seed */
        batch.set(settingsDocRef, billingData);

        await batch.commit();

        res.status(200).send("✅ Plantilla de configuración limpia y creado en app_defaults.");
    } catch (error) {
        console.error("Error en seedDefaultConfig:", error);
        res.status(500).send("❌ Error al procesar la operación");
    }
});