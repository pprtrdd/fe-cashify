import * as admin from "firebase-admin";
admin.initializeApp();

export { seedAppConfig } from "./seed/appConfig";
export { seedDefaultCategories } from "./seed/defaultCategories";
export { seedDefaultConfig } from "./seed/defaultConfig";
export { seedPaymentMethods } from "./seed/paymentMethods";