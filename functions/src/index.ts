import * as admin from "firebase-admin";
admin.initializeApp();

export { seedAppConfig } from "./seed/appConfig";
export { seedPaymentMethods } from "./seed/paymentMethods";