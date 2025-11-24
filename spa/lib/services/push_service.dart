import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _api = ApiService();

  Future<void> init() async {
    // Запрос разрешений на уведомления (особенно важно для iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Получаем initial токен и регистрируем устройство, если юзер залогинен
    await _syncToken();

    // Слушаем обновления токена
    _messaging.onTokenRefresh.listen((token) {
      _registerToken(token);
    });

    // Обработка уведомлений в форграунде (по желанию можно навесить кастомный UI)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Можно добавить локальные уведомления или логирование
    });

    // Обработка нажатий по уведомлению
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final campaignId = message.data['campaign_id'];
      if (campaignId != null) {
        // TODO: Навигация на экран кампании/акции
      }
    });
  }

  Future<void> _syncToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }
  }

  Future<void> _registerToken(String token) async {
    final isAuth = AuthService().isAuthenticated;
    if (!isAuth) return;

    try {
      await _api.post('/devices/register', {
        'token': token,
        'platform': 'android', // TODO: различать android/ios при необходимости
      });
    } catch (_) {
      // Игнорируем ошибки регистрации, можно добавить лог
    }
  }

  Future<void> unregister() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _api.post('/devices/unregister', {'token': token});
      }
    } catch (_) {
      // Игнорируем ошибки
    }
  }
}


