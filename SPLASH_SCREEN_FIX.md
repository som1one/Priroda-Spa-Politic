# Исправление Splash Screen - Инструкция

## Проблема
Изменения в splash screen не применяются после пересборки.

## Решение - Полная очистка и пересборка

### Шаг 1: Очистка Flutter кэша
```bash
cd spa
flutter clean
```

### Шаг 2: Очистка Android кэша (если есть доступ к Gradle)
```bash
cd spa/android
./gradlew clean
```

Или вручную удали папки:
- `spa/android/.gradle`
- `spa/android/app/build`
- `spa/android/build`

### Шаг 3: Удаление приложения с устройства
**ВАЖНО!** Удали приложение с устройства/эмулятора перед переустановкой:
- На устройстве: Настройки → Приложения → PRIRODA SPA → Удалить
- Или через ADB: `adb uninstall com.prirodaspa.app`

### Шаг 4: Пересборка и установка
```bash
cd spa
flutter pub get
flutter run --release
```

Или для установки APK:
```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Проверка файлов

Убедись, что файлы настроены правильно:

### 1. `spa/android/app/src/main/res/drawable/launch_background.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Цвет фона -->
    <item android:drawable="@color/splash_background" />
    
    <!-- Логотип в центре, не растягивается -->
    <item>
        <bitmap
            android:src="@drawable/splash_priroda"
            android:gravity="center" />
    </item>
</layer-list>
```

### 2. `spa/android/app/src/main/res/values/colors.xml`
```xml
<color name="splash_background">#FFFFFF</color>
```

### 3. `spa/android/app/src/main/res/values/styles.xml`
```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">@drawable/launch_background</item>
    <item name="android:windowNoTitle">true</item>
    <item name="android:windowFullscreen">false</item>
</style>
```

### 4. `spa/android/app/src/main/AndroidManifest.xml`
```xml
<activity
    android:name=".MainActivity"
    android:theme="@style/LaunchTheme"
    ...>
```

## Если всё ещё не работает

1. **Проверь, что файл `splash_priroda.png` существует:**
   - Путь: `spa/android/app/src/main/res/drawable/splash_priroda.png`

2. **Проверь размер изображения:**
   - Рекомендуется: 512×512 или 1024×1024 пикселей
   - Формат: PNG с прозрачностью (если нужно)

3. **Попробуй изменить цвет фона для теста:**
   - В `colors.xml` измени `#FFFFFF` на `#FF0000` (красный)
   - Если красный фон появится, значит проблема в изображении

4. **Проверь, нет ли других файлов splash:**
   - Убедись, что нет `flutter_native_splash` конфигурации в `pubspec.yaml`
   - Убедись, что нет других `launch_background.xml` в других папках `res`

5. **Полная пересборка без кэша:**
   ```bash
   flutter clean
   flutter pub get
   cd android
   ./gradlew clean
   cd ..
   flutter build apk --release
   ```

## Альтернативное решение

Если проблема сохраняется, попробуй создать новый drawable файл:

1. Создай `spa/android/app/src/main/res/drawable/splash_logo.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/splash_priroda"
    android:gravity="center" />
```

2. Обнови `launch_background.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_background" />
    <item android:drawable="@drawable/splash_logo" />
</layer-list>
```

