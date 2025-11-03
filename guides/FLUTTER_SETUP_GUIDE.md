# Пошаговый Гайд: Создание Flutter Проекта

## Предварительные требования

### 1. Установка Flutter SDK

**Для Windows:**
1. Скачайте Flutter SDK с официального сайта: https://docs.flutter.dev/get-started/install/windows
2. Распакуйте архив в желаемую директорию (например, `C:\src\ flutter`)
3. НЕ помещайте Flutter в директорию с пробелами или специальными символами (например, `C:\Program Files\`)

### 2. Добавление Flutter в PATH

1. Откройте "Переменные среды" (Environment Variables)
2. Найдите переменную `Path` в системных переменных
3. Добавьте путь к `flutter\bin` (например, `C:\src\flutter\bin`)
4. Нажмите OK для сохранения

### 3. Установка дополнительного ПО

**Обязательные компоненты:**
- **Git** - https://git-scm.com/download/win
- **Android Studio** - https://developer.android.com/studio
  - Включает Android SDK и эмулятор
  - Установите Flutter и Dart плагины через Settings → Plugins

**Опционально:**
- **Visual Studio Code** с расширением Flutter
- **Chrome** для веб-разработки

### 4. Проверка установки

Откройте PowerShell или командную строку и выполните:

```bash
flutter doctor
```

Эта команда проверит окружение и укажет, что нужно доустановить.

---

## Создание нового проекта

### Способ 1: Через командную строку (Terminal)

**Перейдите в вашу рабочую директорию:**
```bash
cd D:\PycharmProjects
```

**Создайте Flutter проект:**
```bash
flutter create spa
```

**Где:**
- `spa` - имя вашего проекта (будет создана папка с этим именем)

**Дополнительные опции:**
```bash
flutter create --org com.example --project-name spa spa
```

- `--org` - организация (используется в пакетах)
- `--project-name` - внутреннее имя проекта

### Способ 2: Через Android Studio/IntelliJ IDEA

1. Откройте Android Studio/IntelliJ
2. File → New → New Flutter Project
3. Выберите "Flutter Application"
4. Укажите путь к проекту: `D:\PycharmProjects\Spa`
5. Нажмите Finish

### Способ 3: Через Visual Studio Code

1. Откройте VS Code
2. Нажмите `Ctrl+Shift+P`
3. Введите "Flutter: New Project"
4. Выберите "Application"
5. Укажите директорию и имя проекта

---

## Структура проекта

После создания проекта вы увидите следующую структуру:

```
spa/
├── android/          # Нативный Android код
├── ios/              # Нативный iOS код
├── lib/              # Основной код приложения (здесь пишете)
│   ├── main.dart     # Точка входа
├── test/             # Тесты
├── web/              # Веб-версия
├── pubspec.yaml      # Зависимости проекта
├── README.md
└── analysis_options.yaml  # Настройки анализатора кода
```

---

## Первый запуск

### Запуск на эмуляторе Android

1. Запустите Android Studio
2. Tools → AVD Manager
3. Создайте новый виртуальный девайс (Create Virtual Device)
4. Выберите устройство (например, Pixel 5)
5. Выберите образ системы (рекомендуется последний стабильный)
6. Нажмите Finish
7. Запустите эмулятор (зеленая кнопка Play)

**Затем в терминале:**
```bash
cd D:\PycharmProjects\Spa
flutter run
```

### Запуск на физическом устройстве

**Android:**
1. Включите режим разработчика на телефоне
2. Включите отладку по USB
3. Подключите телефон к компьютеру
4. Выполните `flutter devices` для проверки
5. Выполните `flutter run`

**iOS (только для Mac):**
1. Подключите iPhone
2. Доверьте компьютеру на телефоне
3. Выполните `flutter run`

### Запуск в веб-браузере

```bash
flutter run -d chrome
```

---

## Основные команды Flutter

### Управление проектом
```bash
# Создать новый проект
flutter create project_name

# Запустить приложение
flutter run

# Запустить на конкретном устройстве
flutter run -d device_id

# Остановить приложение
flutter run (затем нажмите q)

# Собрать приложение (release)
flutter build apk        # Android APK
flutter build ios        # iOS app
flutter build web        # Web app
```

### Управление зависимостями
```bash
# Получить зависимости
flutter pub get

# Обновить зависимости
flutter pub upgrade

# Добавить зависимость
flutter pub add package_name

# Удалить зависимость
flutter pub remove package_name
```

### Диагностика
```bash
# Проверить окружение
flutter doctor

# Проверить подключенные устройства
flutter devices

# Очистить кэш сборки
flutter clean

# Обновить Flutter
flutter upgrade
```

### Прочие команды
```bash
# Запустить тесты
flutter test

# Анализ кода
flutter analyze

# Форматирование кода
flutter format lib/

# Генерация кода (для пакетов вроде json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Редактирование кода

### Основной файл приложения

Откройте `lib/main.dart` - это точка входа приложения.

**Стандартный код по умолчанию:**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Добавление зависимостей

Отредактируйте файл `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Добавьте свои зависимости здесь
  cupertino_icons: ^1.0.2
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

Затем выполните:
```bash
flutter pub get
```

---

## Полезные ресурсы

### Официальная документация
- Flutter: https://docs.flutter.dev/
- Dart: https://dart.dev/

### Обучение
- Flutter Cookbook: https://docs.flutter.dev/cookbook
- YouTube канал Flutter: https://www.youtube.com/c/flutterdev

### Популярные пакеты
- **http** - HTTP запросы
- **provider/bloc** - управление состоянием
- **shared_preferences** - локальное хранилище
- **sqflite** - база данных SQLite
- **image_picker** - выбор изображений
- **url_launcher** - открытие ссылок

---

## Типичные проблемы и решения

### Проблема: "flutter: command not found"
**Решение:** Добавьте Flutter в PATH (см. раздел "Установка")

### Проблема: Не запускается эмулятор
**Решение:** Проверьте, что в Android Studio установлены Android SDK и эмулятор

### Проблема: "Waiting for another flutter command to release the startup lock"
**Решение:** 
```bash
flutter clean
```

### Проблема: Медленная сборка
**Решение:**
- Используйте профиль сборки: `flutter run --profile`
- Убедитесь, что включен режим Release для продакшена

---

## Следующие шаги

1. Изучите основы Dart (язык программирования Flutter)
2. Пройдите кучу примеров из Flutter Cookbook
3. Создайте свой первый проект с нуля
4. Изучите управление состоянием (Provider/Bloc)
5. Научитесь работать с API
6. Создайте и опубликуйте первое приложение

**Удачи в разработке на Flutter! 🚀**

