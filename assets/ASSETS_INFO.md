# Инструкция по добавлению иконок

## Необходимые файлы

Для корректного отображения кнопок социального входа нужны следующие иконки:

### Google Logo
- **Путь**: `assets/images/google_logo.png`
- **Размер**: 20x20 пикселей
- **Формат**: PNG с прозрачным фоном
- **Цвета**: Официальные цвета Google (красный, желтый, зеленый, синий)

### Apple Logo
- **Путь**: `assets/images/apple_logo.png`
- **Размер**: 20x20 пикселей
- **Формат**: PNG с прозрачным фоном
- **Цвет**: Черный (#212121)

## Где найти иконки

1. **Google Logo**: 
   - Официальный брендбук Google: https://about.google/brand-resource-center/
   - Или используйте иконку из Material Icons с кастомизацией

2. **Apple Logo**:
   - Официальный брендбук Apple: https://developer.apple.com/design/resources/
   - Или используйте стандартную иконку Apple

## Альтернатива: Использование SVG

Если хотите использовать SVG (рекомендуется для масштабирования):

1. Добавьте пакет `flutter_svg` в `pubspec.yaml`:
```yaml
dependencies:
  flutter_svg: ^2.0.9
```

2. Сохраните SVG файлы:
   - `assets/images/google_logo.svg`
   - `assets/images/apple_logo.svg`

3. Обновите код в `registration_screen.dart` для использования `SvgPicture.asset()` вместо `Image.asset()`

## Важно

Если файлы отсутствуют, приложение будет использовать fallback иконки (Material Icons), поэтому приложение не сломается, но рекомендуется добавить официальные логотипы.

