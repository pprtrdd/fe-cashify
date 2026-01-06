import 'package:intl/intl.dart';

class Formatters {
  static String currency(num amount) {
    return NumberFormat.decimalPattern('es_CL').format(amount);
  }

  static String currencyWithSymbol(num amount) {
    return '\$${currency(amount)}';
  }
}
