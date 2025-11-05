import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  bool _isAuthenticated = false;
  final _apiService = ApiService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get isAuthenticated => _isAuthenticated;

  String? get token => _token;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      _token = response['access_token'];
      _apiService.token = _token;
      _isAuthenticated = true;
      
      return true;
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      _apiService.token = null;
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      // TODO: Реализовать логику регистрации
      // final response = await ApiService().post('/auth/register', {
      //   'email': email,
      //   'password': password,
      //   'name': name,
      // });
      
      // _token = response['token'];
      // _isAuthenticated = true;
      
      // Имитация регистрации
      await Future.delayed(const Duration(seconds: 1));
      _token = 'fake_token_${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;
      
      return true;
    } catch (e) {
      _isAuthenticated = false;
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    // TODO: Очистить локальное хранилище
  }

  Future<bool> checkAuth() async {
    // TODO: Проверить наличие токена в хранилище
    return _isAuthenticated;
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Запускаем Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // Пользователь отменил вход
        return false;
      }

      // Получаем auth детали от Google
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Создаем credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Входим в Firebase
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      // Получаем токен для вашего бэкенда
      final idToken = await userCredential.user?.getIdToken();
      
      if (idToken != null && userCredential.user != null) {
        // Отправляем токен на ваш бэкенд для создания/обновления пользователя
        final user = userCredential.user!;
        final response = await _apiService.post('/auth/google', {
          'id_token': idToken,
          'email': user.email,
          'name': user.displayName ?? '',
          'photo_url': user.photoURL,
        });

        _token = response['access_token'];
        _apiService.token = _token;
        _isAuthenticated = true;
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Ошибка Google Sign-In: $e');
      _isAuthenticated = false;
      _token = null;
      _apiService.token = null;
      return false;
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await logout();
  }
}

