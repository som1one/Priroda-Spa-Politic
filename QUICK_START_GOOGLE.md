# Быстрый старт: Google Sign-In

## Что уже сделано

✅ Добавлены зависимости в `pubspec.yaml`  
✅ Обновлен `AuthService` для поддержки Google Sign-In  
✅ Обновлен `RegistrationScreen` для подключения кнопки  
✅ Добавлен эндпоинт `/auth/google` на бэкенде  
✅ Настроены Android Gradle файлы  

## Что нужно сделать вам

### 1. Установить зависимости Flutter

```bash
cd spa
flutter pub get
```

### 2. Настроить Firebase (подробный гайд в GOOGLE_SIGNIN_SETUP.md)

1. Создайте проект на https://console.firebase.google.com/
2. Добавьте Android и iOS приложения
3. Скачайте `google-services.json` (Android) и `GoogleService-Info.plist` (iOS)
4. Включите Google Sign-In в Firebase Console → Authentication → Sign-in method

### 3. Инициализировать Firebase в коде

```bash
cd spa
flutter pub global activate flutterfire_cli
flutterfire configure
```

После этого создайте или обновите `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 4. Получить Google Client ID

1. В Firebase Console → Project Settings → General
2. Найдите Web app → скопируйте Client ID
3. ИЛИ в Google Cloud Console → APIs & Services → Credentials → OAuth 2.0 Client ID

### 5. Настроить бэкенд

Добавьте в `backend/.env`:

```
GOOGLE_CLIENT_ID=ваш_client_id.apps.googleusercontent.com
```

Установите зависимости:

```bash
cd backend
pip install -r requirements.txt
```

### 6. Проверить файлы

- ✅ `spa/android/app/google-services.json` (добавить после настройки Firebase)
- ✅ `spa/ios/Runner/GoogleService-Info.plist` (добавить после настройки Firebase)
- ✅ `spa/lib/firebase_options.dart` (создастся после `flutterfire configure`)

## Готово!

После выполнения всех шагов Google Sign-In будет работать. Полный гайд с деталями в `GOOGLE_SIGNIN_SETUP.md`.

