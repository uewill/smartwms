import 'package:intl/intl.dart';

class FormatterUtil {
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'zh_CN');
    return formatter.format(amount);
  }

  static String formatAmountNoSymbol(double amount) {
    final formatter = NumberFormat('#,##0.00', 'zh_CN');
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd', 'zh_CN');
    return formatter.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN');
    return formatter.format(dateTime);
  }

  static String formatShortDateTime(DateTime dateTime) {
    final formatter = DateFormat('MM-dd HH:mm', 'zh_CN');
    return formatter.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm', 'zh_CN');
    return formatter.format(dateTime);
  }

  static String maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    if (phone.length < 7) return phone;
    final start = phone.substring(0, 3);
    final end = phone.substring(phone.length - 4);
    return '$start****$end';
  }

  static String formatQuantity(int quantity) {
    if (quantity >= 10000) {
      return '${(quantity / 10000).toStringAsFixed(1)}万';
    }
    return quantity.toString();
  }

  static String formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}
