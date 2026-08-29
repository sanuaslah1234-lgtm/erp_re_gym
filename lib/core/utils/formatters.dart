import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy hh:mm a');

  static String currency(double value) {
    return _currencyFormat.format(value);
  }

  static String date(DateTime? date) {
    if (date == null) return 'N/A';
    return _dateFormat.format(date);
  }

  static String dateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return _dateTimeFormat.format(date);
  }
}
