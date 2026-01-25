import 'package:intl/intl.dart';

class Formatters {
  static const String _locale = 'es_CL';

  static String currency(num amount) {
    return NumberFormat.decimalPattern(_locale).format(amount.abs());
  }

  static String currencyWithSymbol(num amount) {
    final String sign = amount < 0 ? '-' : '';
    return '$sign\$${currency(amount)}';
  }
}
