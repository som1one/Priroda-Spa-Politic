import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/api_exceptions.dart';

class YClientsBookingScreen extends StatefulWidget {
  final int serviceId;
  final Map<String, dynamic>? service;

  const YClientsBookingScreen({
    super.key,
    required this.serviceId,
    this.service,
  });

  @override
  State<YClientsBookingScreen> createState() => _YClientsBookingScreenState();
}

class _YClientsBookingScreenState extends State<YClientsBookingScreen> {
  final _apiService = ApiService();
  final _authService = AuthService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _openBookingForm();
  }

  Future<void> _openBookingForm() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = _authService.token;
      if (token != null) {
        _apiService.token = token;
      }

      // Получаем URL формы
      final endpoint = '/yclients/widget-url/${widget.serviceId}';
      final response = await _apiService.get(endpoint);
      
      if (response is Map && response.containsKey('widget_url')) {
        final widgetUrl = response['widget_url'] as String;
        
        if (!mounted) return;
        
        // Открываем ссылку в браузере
        final uri = Uri.parse(widgetUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          // Закрываем экран после открытия ссылки
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          throw Exception('Не удалось открыть ссылку');
        }
      } else {
        throw Exception('Неверный формат ответа от сервера');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = getErrorMessage(e);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${getErrorMessage(e)}'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Забронировать услугу'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorState();
    }

    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Открываем форму записи...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Не удалось открыть форму записи',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }
}

