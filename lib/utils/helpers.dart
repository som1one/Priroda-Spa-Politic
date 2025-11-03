class Helpers {
  /// Форматирование даты и времени
  static String formatDateTime(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Форматирование даты
  static String formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
  
  /// Форматирование валюты
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ₽';
  }
  
  /// Обрезка текста
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Проверка интернета
  static Future<bool> checkInternetConnection() async {
    // TODO: Реализовать проверку подключения к интернету
    return true;
  }
}

