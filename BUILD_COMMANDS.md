# Команды для сборки приложения

## 1. Очистка (уже выполнена)
```bash
cd spa
flutter clean
```

## 2. Получение зависимостей
```bash
flutter pub get
```

## 3. Сборка для тестирования (Debug)
```bash
flutter run
```
или для конкретного устройства:
```bash
flutter run -d <device_id>
```

## 4. Сборка Release APK
```bash
flutter build apk --release
```
APK будет в: `build/app/outputs/flutter-apk/app-release.apk`

## 5. Сборка Release App Bundle (для Google Play)
```bash
flutter build appbundle --release
```
AAB будет в: `build/app/outputs/bundle/release/app-release.aab`

## 6. Установка на устройство

### Через ADB (если устройство подключено):
```bash
# Для APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Или удалить старое и установить новое
adb uninstall com.prirodaspa.app
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Через Flutter:
```bash
flutter install
```

## Важно для Splash Screen

После изменений в splash screen:
1. **Удали старое приложение** с устройства (важно!)
2. Выполни `flutter clean`
3. Собери заново
4. Установи на устройство

## Проверка изменений

Чтобы увидеть изменения в splash screen:
- Удали приложение полностью
- Пересобери и установи заново
- Splash screen показывается только при первом запуске после установки

