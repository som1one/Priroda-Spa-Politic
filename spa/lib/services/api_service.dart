import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  set token(String? value) {
    _token = value;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}$endpoint');
      final response = await http
          .get(url, headers: _headers)
          .timeout(AppConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Ошибка GET запроса: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic>? data, {
    bool throwOnError = true,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}$endpoint');
      final response = await http
          .post(
            url,
            headers: _headers,
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(AppConstants.connectionTimeout);

      if (throwOnError) {
        return _handleResponse(response);
      } else {
        return _handleResponse(response);
      }
    } catch (e) {
      if (throwOnError) {
        throw Exception('Ошибка POST запроса: $e');
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}$endpoint');
      final response = await http
          .put(
            url,
            headers: _headers,
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(AppConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Ошибка PUT запроса: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}$endpoint');
      final response = await http
          .delete(url, headers: _headers)
          .timeout(AppConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Ошибка DELETE запроса: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic> responseBody;
    
    try {
      responseBody = json.decode(response.body);
    } catch (e) {
      responseBody = {'message': response.body};
    }

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else if (statusCode == 401) {
      throw Exception(responseBody['detail'] ?? responseBody['message'] ?? 'Не авторизован');
    } else if (statusCode == 404) {
      throw Exception(responseBody['detail'] ?? responseBody['message'] ?? 'Ресурс не найден');
    } else {
      throw Exception(responseBody['detail'] ?? responseBody['message'] ?? 'Ошибка сервера');
    }
  }
}

