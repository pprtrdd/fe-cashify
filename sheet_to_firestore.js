/* 
  Use env values to config this script
  project_id: FIREBASE_PROJECT_ID
  client_email: FIREBASE_CLIENT_EMAIL
  private_key: FIREBASE_PRIVATE_KEY
  USER_ID = FIREBASE_USER_ID
*/

const FIREBASE_CONFIG = {
  project_id: "...",
  client_email: "...",
  private_key: "..."
};

const USER_ID = "...";
const DEBUG_MODE = false;

const SessionCache = { billingPeriodIds: {}, categories: {} };

function exportFullSpreadsheetToFirestore() {
  const firestore = FirestoreApp.getFirestore(
    FIREBASE_CONFIG.client_email,
    FIREBASE_CONFIG.private_key,
    FIREBASE_CONFIG.project_id
  );

  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheets = ss.getSheets();
  const dateInfo = extractDateFromFileName(ss.getName());

  let totalDocs = 0;
  const paymentMethodMap = { "Crédito": "CREDIT", "Credito": "CREDIT", "Débito": "DEBIT", "Debito": "DEBIT", "Efectivo": "CASH" };

  for (let s = 1; s < sheets.length; s++) {
    let categoryTotalDocs = 0;
    const currentSheet = sheets[s];
    const categoryName = currentSheet.getName();
    const categoryId = categoryName.toUpperCase().replace(/\s+/g, '_');

    if (!DEBUG_MODE && !SessionCache.categories[categoryId]) {
      ensureExists(firestore, `users/${USER_ID}/categories`, categoryId, {
        name: categoryName, isExpense: true, isSystem: false, isExtra: false
      });
      SessionCache.categories[categoryId] = true;
    }

    const data = currentSheet.getDataRange().getValues();
    Logger.log(`🚀 Procesando ${categoryName}`);

    for (let i = 2; i < data.length; i++) {
      const row = data[i];
      if (!row[0]) continue;

      let currentInst = 1, totalInst = 1;
      const instRaw = row[5] ? row[5].toString() : "1/1";
      if (instRaw.includes('/')) {
        const parts = instRaw.split('/');
        currentInst = parseInt(parts[0]);
        totalInst = parseInt(parts[1]);
      }

      const groupId = Utilities.getUuid();
      const methodId = paymentMethodMap[row[6].toString().trim()];

      for (let n = currentInst; n <= totalInst; n++) {
        const offset = n - currentInst;
        const targetDate = new Date(dateInfo.year, (dateInfo.month - 1) + offset, 2);
        const tYear = targetDate.getFullYear();
        const tMonth = targetDate.getMonth() + 1;
        const tBillingPeriodId = `${tYear}_${tMonth}`;
        const isOriginal = (n === currentInst);

        if (!DEBUG_MODE) {
          if (!SessionCache.billingPeriodIds[tBillingPeriodId]) {
            ensureExists(firestore, `users/${USER_ID}/billing_periods`, tBillingPeriodId, {
              id: tBillingPeriodId, year: tYear, month: tMonth, lastUpdate: new Date(), status: "active"
            });
            SessionCache.billingPeriodIds[tBillingPeriodId] = true;
          }

          const transaction = {
            userId: USER_ID,
            categoryId,
            description: row[0].toString(),
            source: row[1] ? row[1].toString() : "",
            quantity: Number(row[2]) || 1,
            amount: Number(row[3]),
            currentInstallment: n,
            totalInstallments: totalInst,
            paymentMethodId: methodId,
            billingPeriodMonth: tMonth,
            billingPeriodYear: tYear,
            billingPeriodId: tBillingPeriodId,
            notes: row[7] ? row[7].toString() : null,
            createdAt: new Date(),
            updatedAt: new Date(),
            groupId: groupId,
            isCompleted: isOriginal ? (Number(row[2]) !== 0) : false,
          };

          /* TODO: Rename collection 'movements' to 'transactions' */
          firestore.createDocument(`users/${USER_ID}/billing_periods/${tBillingPeriodId}/movements`, transaction);
          totalDocs++;
          categoryTotalDocs++;
        }
      }

      Logger.log(`✅ Procesado ${categoryName}: ${row[0].toString()} creado.`);
    }

    Logger.log(`✅ Procesado ${categoryName}: ${categoryTotalDocs} registros.`);
  }

  Logger.log(`✅ Finalizado: ${totalDocs} registros creados.`);
}

function extractDateFromFileName(name) {
  try {
    const parts = name.split(" - ");
    const dateParts = parts[1].split("/");
    return { year: parseInt(dateParts[0]), month: parseInt(dateParts[1]) };
  } catch (e) {
    return { month: new Date().getMonth() + 1, year: new Date().getFullYear() };
  }
}

function ensureExists(db, path, id, data) {
  try {
    db.getDocument(`${path}/${id}`);
  } catch (e) {
    db.createDocument(`${path}/${id}`, data);
  }
}

function exportToFirestore() {
  exportFullSpreadsheetToFirestore();
}