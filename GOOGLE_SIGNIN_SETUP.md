# Гайд по настройке Google Sign-In через Firebase

## Шаг 1: Создание проекта Firebase

1. Перейдите на https://console.firebase.google.com/
2. Нажмите "Добавить проект" (Add project)
3. Введите название проекта (например, "SPA Salon")
4. Отключите Google Analytics (или оставьте включенным по желанию)
5. Нажмите "Создать проект"

## Шаг 2: Добавление Android приложения

1. В Firebase Console нажмите на иконку Android или "Add app" → Android
2. Введите Package name:
   - Откройте файл `spa/android/app/build.gradle.kts`
   - Найдите `namespace` (обычно `com.example.spa`)
   - Введите этот package name в Firebase
3. Введите App nickname (опционально, например "SPA Android")
4. Нажмите "Register app"
5. **Скачайте файл `google-services.json`**
6. Скопируйте `google-services.json` в `spa/android/app/`

## Шаг 3: Настройка Android проекта

Откройте `spa/android/build.gradle.kts` и добавьте в `buildscript` → `dependencies`:

```kotlin
buildscript {
    dependencies {
        // ... существующие зависимости
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

Откройте `spa/android/app/build.gradle.kts` и добавьте в конец файла:

```kotlin
apply(plugin = "com.google.gms.google-services")
```

## Шаг 4: Добавление iOS приложения

1. В Firebase Console нажмите "Add app" → iOS
2. Введите Bundle ID:
   - Откройте `spa/ios/Runner.xcodeproj/project.pbxproj` или используйте Xcode
   - Найдите `PRODUCT_BUNDLE_IDENTIFIER` (обычно `com.example.spa`)
   - Введите этот Bundle ID в Firebase
3. Введите App nickname (опционально)
4. Нажмите "Register app"
5. **Скачайте файл `GoogleService-Info.plist`**
6. Откройте проект в Xcode:
   ```bash
   cd spa/ios
   open Runner.xcworkspace
   ```
7. В Xcode перетащите `GoogleService-Info.plist` в папку `Runner` (убедитесь, что выбрана опция "Copy items if needed")

## Шаг 5: Настройка iOS проекта

1. В Xcode откройте `Info.plist`
2. Добавьте URL Scheme:
   - Откройте `GoogleService-Info.plist` в текстовом редакторе
   - Найдите `REVERSED_CLIENT_ID` (что-то вроде `com.googleusercontent.apps.123456789`)
   - В `Info.plist` добавьте:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>ВАШ_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

## Шаг 6: Включение Google Sign-In в Firebase

1. В Firebase Console перейдите в **Authentication** → **Sign-in method**
2. Нажмите на **Google**
3. Включите переключатель "Enable"
4. Введите **Support email** (ваш email)
5. Нажмите "Save"

## Шаг 7: Получение Client ID для бэкенда

1. В Firebase Console перейдите в **Project Settings** (шестеренка рядом с "Project Overview")
2. Перейдите на вкладку **General**
3. Найдите секцию **Your apps**
4. Выберите **Web app** (если нет, нажмите "Add app" → Web, укажите любое название)
5. Найдите **Web API Key** или скопируйте **OAuth 2.0 Client ID** из секции "SDK setup and configuration"
6. **ИЛИ** используйте Client ID напрямую:
   - Перейдите в Google Cloud Console: https://console.cloud.google.com/
   - Выберите ваш проект Firebase
   - Перейдите в **APIs & Services** → **Credentials**
   - Найдите OAuth 2.0 Client ID типа "Web application"
   - Скопируйте **Client ID** (он будет выглядеть как `xxxxx.apps.googleusercontent.com`)

## Шаг 8: Настройка бэкенда

1. Откройте файл `.env` в папке `backend/`
2. Добавьте строку:
   ```
   GOOGLE_CLIENT_ID=ваш_client_id_из_шага_7.apps.googleusercontent.com
   ```
   Например:
   ```
   GOOGLE_CLIENT_ID=123456789-abc123def456.apps.googleusercontent.com
   ```

## Шаг 9: Установка зависимостей Flutter

Выполните в терминале:

```bash
cd spa
flutter pub get
```

## Шаг 10: Инициализация Firebase в приложении

Создайте файл `spa/lib/firebase_options.dart` автоматически:

```bash
cd spa
flutter pub global activate flutterfire_cli
flutterfire configure
```

Выберите ваш проект Firebase и платформы (Android, iOS).

После этого обновите `spa/lib/app.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

## Шаг 11: Установка зависимостей бэкенда

```bash
cd backend
pip install -r requirements.txt
```

## Шаг 12: Тестирование

1. Запустите бэкенд:
   ```bash
   cd backend
   uvicorn app.main:app --reload
   ```

2. Запустите Flutter приложение:
   ```bash
   cd spa
   flutter run
   ```

3. На экране регистрации нажмите "Войти с помощью Google"
4. Должно открыться окно выбора Google аккаунта
5. После выбора аккаунта вы должны быть авторизованы

## Важные замечания

1. **SHA-1 для Android** (для production):
   - Получите SHA-1 ключ:
     ```bash
     cd android
     ./gradlew signingReport
     ```
   - Добавьте SHA-1 в Firebase Console → Project Settings → Your apps → Android app → Add fingerprint

2. **OAuth consent screen** (для production):
   - В Google Cloud Console настройте OAuth consent screen
   - Укажите название приложения, email поддержки, и т.д.

3. **Проверка в production**:
   - Убедитесь, что в Firebase Console добавлены правильные SHA-1/SHA-256 для production ключей
   - Проверьте, что OAuth consent screen опубликован

## Решение проблем

### Ошибка "Sign in with Google temporarily disabled"
- Проверьте, что Google Sign-In включен в Firebase Console
- Убедитесь, что SHA-1 ключ добавлен в Firebase для Android

### Ошибка "DEVELOPER_ERROR" на Android
- Проверьте, что `google-services.json` находится в `android/app/`
- Убедитесь, что в `build.gradle.kts` добавлен plugin `google-services`

### Ошибка верификации токена на бэкенде
- Проверьте, что `GOOGLE_CLIENT_ID` правильный в `.env`
- Убедитесь, что Client ID соответствует Web application в Google Cloud Console

