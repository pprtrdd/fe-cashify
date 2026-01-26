import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

interface CategorySeed {
    id: string;
    name: string;
    isExpense: boolean;
    isExtra: boolean;
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
        { id: "PETS", name: "Mascotas", isExpense: true, isExtra: false },
        { id: "HEALTH", name: "Salud", isExpense: true, isExtra: false },
        { id: "HOME", name: "Hogar", isExpense: true, isExtra: false },
        { id: "MARKET", name: "Supermercado", isExpense: true, isExtra: false },
        { id: "PERSONAL", name: "Personal", isExpense: true, isExtra: false },
        { id: "SUBSCRIPTIONS", name: "Subscripciones", isExpense: true, isExtra: false },
        { id: "TRANSPORT", name: "Transporte", isExpense: true, isExtra: false },
        { id: "MISC", name: "Miscelaneo", isExpense: true, isExtra: false },
        { id: "PAYMENTS", name: "Ingresos", isExpense: false, isExtra: false },
        { id: "EXTRA_MISC", name: "Gastos Hormiga", isExpense: true, isExtra: true },
        { id: "EXTRA_PAYMENTS", name: "Ingresos extras", isExpense: false, isExtra: true },
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
            const docRef = collectionRef.doc(cat.id);
            batch.set(docRef, {
                name: cat.name,
                isExpense: cat.isExpense,
                isExtra: cat.isExtra,
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            });
        });

        await batch.commit();

        res.status(200).send(`✅ Plantilla de categorías limpia y ${categories.length} items creados en app_defaults.`);
    } catch (error) {
        console.error("Error en seedDefaultCategories:", error);
        res.status(500).send("❌ Error al procesar la operación");
    }
});