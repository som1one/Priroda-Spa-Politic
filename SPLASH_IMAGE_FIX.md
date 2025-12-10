# Исправление проблемы с изображением Splash Screen

## Проблема
Изображение `splash_priroda.png` имеет размеры **796×582 пикселей** (не квадратное), что может вызывать растяжение или искажение.

## Решение

### Вариант 1: Подготовить квадратное изображение (рекомендуется)

1. Открой `splash_priroda.png` в графическом редакторе
2. Создай квадратное изображение **512×512** или **1024×1024** пикселей:
   - Обрежь до квадрата (центрируй логотип)
   - Или добавь прозрачные/белые поля по бокам
3. Сохрани как `splash_priroda.png` в `spa/android/app/src/main/res/drawable/`
4. Пересобери приложение

### Вариант 2: Использовать текущее изображение с ограничением размера

Если не можешь изменить изображение, можно ограничить его максимальный размер в XML:

Обнови `spa/android/app/src/main/res/drawable/splash_logo.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:width="300dp"
        android:height="300dp"
        android:gravity="center">
        <bitmap
            android:src="@drawable/splash_priroda"
            android:gravity="center"
            android:tileMode="disabled" />
    </item>
</layer-list>
```

Это ограничит размер до 300dp и сохранит пропорции.

### Вариант 3: Использовать векторное изображение (SVG)

Если у тебя есть SVG версия логотипа:
1. Конвертируй SVG в Vector Drawable
2. Используй `@drawable/splash_priroda` как вектор

## Рекомендуемые размеры для Android Splash Screen

- **drawable**: 512×512 или 1024×1024 (для всех экранов)
- **drawable-mdpi**: 48×48
- **drawable-hdpi**: 72×72
- **drawable-xhdpi**: 96×96
- **drawable-xxhdpi**: 144×144
- **drawable-xxxhdpi**: 192×192

Но для простоты можно использовать один файл в `drawable` с размером 512×512 или 1024×1024.

## Проверка

После изменений:
1. Удали приложение с устройства
2. Выполни `flutter clean`
3. Пересобери: `flutter run --release`

