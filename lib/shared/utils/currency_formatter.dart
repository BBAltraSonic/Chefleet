import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const String symbol = 'R';
  static const String locale = 'en_ZA';
  
  static final NumberFormat _fmt = NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: 2,
  );
  
  /// Format cents to Rands (e.g., 1550 -> "R15.50")
  static String formatCents(num cents) {
    return _fmt.format(cents / 100);
  }
  
  /// Format decimal to Rands (e.g., 15.50 -> "R15.50")
  static String format(num amount) {
    return _fmt.format(amount);
  }
}
