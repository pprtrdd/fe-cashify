import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

interface CategorySeed {
    name: string;
    isExpense: boolean;
    isExtra: boolean;
    isArchived: boolean;
}

export const seedDefaultCategories = onRequest(async (req, res) => {
    const secret = req.query.secret;

    if (secret !== "c4sh1fy-s3cr3t-985631") {
        res.status(403).send("No autorizado");

        return;
    }

    const db = admin.firestore();
    const collectionRef = db.collection("app_defaults").doc("categories_v1").collection("items");

    const categories: CategorySeed[] = [
        { name: "Mascotas", isExpense: true, isExtra: false, isArchived: false },
        { name: "Salud", isExpense: true, isExtra: false, isArchived: false },
        { name: "Hogar", isExpense: true, isExtra: false, isArchived: false },
        { name: "Supermercado", isExpense: true, isExtra: false, isArchived: false },
        { name: "Gastos personales", isExpense: true, isExtra: false, isArchived: false },
        { name: "Subscripciones", isExpense: true, isExtra: false, isArchived: false },
        { name: "Transporte", isExpense: true, isExtra: false, isArchived: false },
        { name: "Otros", isExpense: true, isExtra: false, isArchived: false },
        { name: "Ingresos", isExpense: false, isExtra: false, isArchived: false },
        { name: "Gastos Hormiga", isExpense: true, isExtra: true, isArchived: false },
        { name: "Ingresos extras", isExpense: false, isExtra: true, isArchived: false },
    ];

    try {
        const batch = db.batch();
        const parentDocRef = db.collection("app_defaults").doc("categories_v1");

        batch.set(parentDocRef, {
            version: 1,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            description: "Plantilla base de categorías"
        });

        /* Clean */
        const currentDocs = await collectionRef.get();
        currentDocs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        /* Seed */
        categories.forEach((cat) => {
            const docRef = collectionRef.doc();
            batch.set(docRef, {
                name: cat.name,
                isExpense: cat.isExpense,
                isExtra: cat.isExtra,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        });

        await batch.commit();

        res.status(200).send(`✅ Plantilla de categorías limpia y ${categories.length} items creados en app_defaults.`);
    } catch (error) {
        console.error("Error en seedDefaultCategories:", error);
        res.status(500).send("❌ Error al procesar la operación");
    }
});