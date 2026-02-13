import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

interface AppConfigData {
    appName: string;
    author: string;
    description: string;
    githubProfile: string;
    linkedinProfile: string;
    supportEmail: string;
    lastYearDeploy: string;
    updatedAt: admin.firestore.FieldValue;
}

export const seedAppConfig = onRequest(async (req, res) => {
    const secret = req.query.secret;

    if (secret !== "c4sh1fy-s3cr3t-985631") {
        res.status(403).send("No autorizado");

        return;
    }

    const db = admin.firestore();
    const collectionRef = db.collection("app_config");

    const appConfig: AppConfigData = {
        appName: "Cashify",
        author: "Paul Rieutord",
        description: "Registrar tus movimientos financieros en pocos pasos.",
        githubProfile: "https://github.com/pprtrdd",
        linkedinProfile: "https://www.linkedin.com/in/paul-rieutord-b3754893",
        supportEmail: "paulr812@gmail.com",
        lastYearDeploy: "2026",
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    try {
        const batch = db.batch();

        /* Clean */
        const currentDocs = await collectionRef.get();

        currentDocs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        /* Seed */
        const aboutRef = collectionRef.doc("about");

        batch.set(aboutRef, appConfig);

        await batch.commit();

        res.status(200).send("✅ Colección limpia y configuración de la App actualizada correctamente");
    } catch (error) {
        console.error("Error seeding app_config:", error);
        res.status(500).send("❌ Error al guardar la configuración");
    }
});