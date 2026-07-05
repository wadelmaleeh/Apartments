import 'package:intl/intl.dart';

class AppConstants {
  static const String appName = 'Apartment Rental';
  static const String currency = 'جنيه';

  static const List<String> expenseTypes = [
    'maintenance',
    'electricity',
    'water',
    'internet',
    'cleaning',
    'repair',
    'insurance',
    'tax',
    'other',
  ];
}

class Formatters {
  static String currency(double amount) {
    // Format with thousand separators: 1,000,000 جنيه
    final formatter = NumberFormat('#,##0.##', 'en_US');
    final formattedAmount = formatter.format(amount);
    return '$formattedAmount ${AppConstants.currency}';
  }

  static String date(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String dateShort(DateTime date) {
    return DateFormat.MMMd().format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }
}
