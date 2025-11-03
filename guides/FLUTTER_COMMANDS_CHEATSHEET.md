# Flutter: Шпаргалка по командам

## 📋 Быстрая справка по командам

### 🚀 Создание и запуск

```bash
# Создать новый проект
flutter create project_name

# Запустить приложение
flutter run

# Запустить с hot reload (по умолчанию)
flutter run --release      # Production режим
flutter run --profile      # Profile режим
flutter run --debug        # Debug режим

# Запустить на конкретном устройстве
flutter run -d chrome      # Web в Chrome
flutter run -d emulator-5554  # Android эмулятор
flutter devices            # Список доступных устройств
```

### 📦 Управление зависимостями

```bash
# Получить все зависимости
flutter pub get

# Обновить зависимости
flutter pub upgrade

# Добавить пакет
flutter pub add package_name

# Добавить dev-зависимость
flutter pub add --dev package_name

# Удалить пакет
flutter pub remove package_name

# Показать устаревшие пакеты
flutter pub outdated
```

### 🏗️ Сборка приложений

```bash
# Android
flutter build apk                    # APK файл
flutter build appbundle             # AAB для Google Play

# iOS
flutter build ios                   # iOS приложение
flutter build ipa                   # IPA файл

# Web
flutter build web                   # Web приложение

# Desktop
flutter build windows               # Windows
flutter build macos                 # macOS
flutter build linux                 # Linux
```

### 🔍 Диагностика

```bash
# Проверить установку и окружение
flutter doctor

# Проверить подключенные устройства
flutter devices

# Анализ кода на ошибки
flutter analyze

# Проверить синтаксис конкретного файла
flutter analyze lib/main.dart

# Показать информацию о проекте
flutter info
```

### 🧹 Очистка и обслуживание

```bash
# Очистить кэш сборки
flutter clean

# После clean нужно снова получить зависимости
flutter pub get

# Обновить Flutter SDK
flutter upgrade

# Обновить только каналы (channels)
flutter channel

# Переключиться на другую версию
flutter channel stable
flutter channel beta
flutter channel dev

# Показать текущую версию Flutter
flutter --version
```

### 🧪 Тестирование

```bash
# Запустить все тесты
flutter test

# Запустить конкретный тест
flutter test test/widget_test.dart

# Тесты с покрытием
flutter test --coverage
```

### 🎨 Форматирование

```bash
# Форматировать весь проект
flutter format .

# Форматировать конкретную директорию
flutter format lib/

# Проверить форматирование без изменений
flutter format --dry-run lib/
```

### 🔧 Разработка

```bash
# Hot reload (во время выполнения приложения)
r  или  R       # В консоли где работает flutter run

# Hot restart
R               # В консоли где работает flutter run

# Остановить приложение
q               # В консоли где работает flutter run

# Генерация кода (для json_serializable, build_runner и т.д.)
flutter pub run build_runner build
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode для автогенерации
flutter pub run build_runner watch
```

### 📱 Эмуляторы и симуляторы

```bash
# Android
# Создать эмулятор через Android Studio:
# Tools → Device Manager → Create Device

# iOS (только Mac)
open -a Simulator

# Показать список всех эмуляторов/симуляторов
flutter emulators

# Запустить конкретный эмулятор
flutter emulators --launch Pixel_5_API_31
```

### 🌐 Модели устройств

```bash
# Список доступных устройств
flutter devices

# Примеры выводов:
# • Chrome (web)            • chrome
# • Edge (web)              • edge
# • Windows (desktop)       • windows
# • Linux (desktop)         • linux
# • macOS (desktop)         • macos
# • iPhone (mobile)         • XXXXXXXXXXXX
# • Android Emulator        • emulator-5554
```

### 🐛 Отладка

```bash
# Запустить с логированием
flutter run --verbose

# Запустить и подключить DevTools
flutter run

# Открыть DevTools в браузере (после запуска)
# Автоматически откроется, или используйте флаг:
flutter run --devtools-server-address http://localhost:9100
```

### 📂 Работа с проектом

```bash
# Создать новый модуль
flutter create --template=package my_package
flutter create --template=module my_module

# Перейти в директорию проекта
cd D:\PycharmProjects\Spa

# Показать структуру проекта
tree /F      # Windows
ls -la       # Linux/Mac

# Инициализировать git (если еще не инициализирован)
git init
git add .
git commit -m "Initial Flutter project"
```

### 🎯 Специальные команды

```bash
# Генерация иконки приложения
flutter pub run flutter_launcher_icons

# Деплой в Firebase
flutter build web
firebase deploy

# Экспорт баз данных/ресурсов
flutter pub global activate dev_tools
flutter pub global run dev_tools

# Установить package глобально
flutter pub global activate package_name

# Использовать глобальный пакет
flutter pub global run package_name
```

### ⚡ Горячие клавиши в консоли (во время flutter run)

| Клавиша | Действие |
|---------|----------|
| `r` | Hot reload (перезагрузить без потери состояния) |
| `R` | Hot restart (полная перезагрузка приложения) |
| `h` | Список всех команд |
| `c` | Очистить консоль |
| `q` | Остановить и выйти |
| `v` | Переключить verbose режим |
| `d` | Открыть DevTools |
| `w` | Дамп приложения (crash dump) |

---

## 🔗 Полезные ресурсы

### Официальные
- Документация: https://docs.flutter.dev
- Cookbook: https://docs.flutter.dev/cookbook
- API: https://api.flutter.dev
- Pub.dev (пакеты): https://pub.dev

### Комьюнити
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Reddit: https://reddit.com/r/FlutterDev
- GitHub: https://github.com/flutter/flutter

### Инструменты
- Flutter DevTools: https://docs.flutter.dev/tools/devtools
- DartPad: https://dartpad.dev (онлайн редактор)

---

## 💡 Совет новичкам

1. **Всегда читайте вывод** `flutter doctor` перед началом работы
2. **Используйте hot reload** (клавиша `r`) для быстрой разработки
3. **Периодически делайте** `flutter clean` при странных ошибках
4. **Обновляйте Flutter регулярно**: `flutter upgrade`
5. **Проверяйте форматирование**: `flutter format .` перед коммитом

---

**Приятной разработки! 🎉**

