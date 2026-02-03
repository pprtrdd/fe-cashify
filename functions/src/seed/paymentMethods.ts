import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

interface PaymentMethodSeed {
    id: string;
    name: string;
}

export const seedPaymentMethods = onRequest(async (req, res) => {
    const secret = req.query.secret;

    if (secret !== "c4sh1fy-s3cr3t-985631") {
        res.status(403).send("No autorizado");

        return;
    }

    const db = admin.firestore();
    const collectionRef = db.collection("payment_methods");
    const paymentMethods: PaymentMethodSeed[] = [
        { id: "CASH", name: "Efectivo" },
        { id: "DEBIT", name: "Tarjeta de Débito" },
        { id: "CREDIT", name: "Tarjeta de Crédito" },
    ];

    try {
        const batch = db.batch();

        /* Clean */
        const currentDocs = await collectionRef.get();

        currentDocs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        /* Seed */
        paymentMethods.forEach((method) => {
            const docRef = collectionRef.doc(method.id);

            batch.set(docRef, {
                name: method.name,
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            });
        });

        await batch.commit();

        res.status(200).send(`✅ Colección limpia y ${paymentMethods.length} métodos creados.`);
    } catch (error) {
        console.error("Error en seedPaymentMethods:", error);
        res.status(500).send("❌ Error al procesar la operación");
    }
});