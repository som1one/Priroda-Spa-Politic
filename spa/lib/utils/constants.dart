class AppConstants {
  // API URLs
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/api/v1';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Default values
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
}

