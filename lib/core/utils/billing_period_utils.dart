class BillingPeriodUtils {
  static String generateId(DateTime date, int startDay) {
    if (date.day >= startDay && startDay > 1) {
      final nextMonth = DateTime(date.year, date.month + 1);
      return "${nextMonth.year}_${nextMonth.month}";
    }
    return "${date.year}_${date.month}";
  }
}
