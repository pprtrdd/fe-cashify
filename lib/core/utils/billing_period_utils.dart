class BillingPeriodUtils {
  static String generateId(DateTime date, int startDay) {
    if (date.day >= startDay && startDay > 1) {
      final nextMonth = DateTime(date.year, date.month + 1);
      return "${nextMonth.year}_${nextMonth.month}";
    }
    return "${date.year}_${date.month}";
  }

  static DateTime getDateFromId(String id) {
    try {
      final parts = id.split('_');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]));
    } catch (e) {
      return DateTime.now();
    }
  }

  static String getNextBillingPeriodId(String periodId) {
    final parts = periodId.split('_');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
    return "${year}_$month";
  }
}
