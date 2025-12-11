# 🔧 Исправление настроек Build в Codemagic

## ✅ Что правильно

1. **Flutter version:** `channel Stable` ✅
2. **Xcode version:** `Latest (26.1)` ✅
3. **CocoaPods version:** `default` ✅
4. **Project path:** `spa` ✅ (это правильно!)
5. **Android build format:** `Android app bundle (AAB)` ✅
6. **Mode:** `Release` ✅

---

## ❌ Что нужно исправить

### Проблема: Build arguments для iOS

**Текущие настройки:**
```
--release --flavor ios-production -t lib/main_prod.dart
```

**Проблема:**
- ❌ Файл `main_prod.dart` не существует в проекте
- ❌ Flavor `ios-production` не настроен в проекте
- ✅ В проекте есть только `main.dart`

---

## ✅ Решение: Исправьте Build arguments

### Для iOS:

**Измените на:**
```
--release
```

**Или если нужен конкретный файл:**
```
--release -t lib/main.dart
```

### Для Android:

**Если `main_prod.dart` существует для Android, оставьте:**
```
--release --flavor android-production -t lib/main_prod.dart
```

**Если нет, измените на:**
```
--release
```

---

## 🎯 Рекомендуемые настройки

### iOS Build arguments:
```
--release
```

### Android Build arguments:
```
--release
```

**Или если у вас есть flavors:**

### iOS:
```
--release -t lib/main.dart
```

### Android:
```
--release -t lib/main.dart
```

---

## ⚠️ Важно проверить

После исправления Build arguments, убедитесь, что:

1. **Code signing настроен:**
   - Перейдите на вкладку **"Code signing"** или **"iOS code signing"**
   - Метод: **Automatic**
   - App Store Connect API key: **"Priroda Spa"**
   - Bundle identifier: `com.prirodaspa.app`
   - Provisioning profile type: **App store**

2. **Bundle ID зарегистрирован:**
   - [developer.apple.com/account](https://developer.apple.com/account) → Identifiers
   - Должен быть: `com.prirodaspa.app`

---

## 📝 Что делать сейчас

1. **Исправьте Build arguments для iOS:**
   - Удалите: `--flavor ios-production -t lib/main_prod.dart`
   - Оставьте только: `--release`
   - Или: `--release -t lib/main.dart`

2. **Проверьте Code signing:**
   - Убедитесь, что настройки code signing правильные
   - Automatic с App Store Connect API ключом

3. **Сохраните и запустите сборку**

---

## ✅ Итоговые настройки

**Build arguments для iOS:**
```
--release
```

**Build arguments для Android:**
```
--release
```
(или с flavor, если он настроен)

**Project path:**
```
spa
```

**Mode:**
```
Release
```

---

**Главное:** Уберите `--flavor ios-production -t lib/main_prod.dart` из iOS build arguments, так как этого файла и flavor нет в проекте!

