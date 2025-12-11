# 🔧 Исправление Shorebird Workflow в Codemagic

## 🚨 Проблема

Выбран workflow **"Shorebird [release]"**, который требует **Shorebird token**. Если вы не используете Shorebird, нужно создать обычный iOS workflow.

Также есть ошибки в Build arguments.

---

## ✅ Решение 1: Создать обычный iOS Workflow (Рекомендуется)

Если вы **НЕ используете Shorebird**:

### Шаг 1: Создайте новый Workflow

1. В Codemagic → Workflows
2. Нажмите **"+"** → **Create workflow**
3. Выберите **"iOS"** или **"Flutter iOS"** (НЕ Shorebird!)

### Шаг 2: Настройте Build

1. **Flutter version:** `channel Stable` (не Shorebird default)
2. **Xcode version:** `Latest (26.1)` ✅
3. **Project path:** `spa` ✅
4. **Build arguments для iOS:**
   - Измените: `release ios -t lib/main.dart`
   - На: `--release`
   - Или: `--release -t lib/main.dart`

5. **Build arguments для Android:**
   - Измените: `release android --target`
   - На: `--release`
   - Или: `--release -t lib/main.dart`

### Шаг 3: Настройте Code Signing

1. Перейдите на вкладку **"Code signing"** или **"Distribution"**
2. **iOS code signing:**
   - Метод: **Automatic**
   - App Store Connect API key: **"Priroda Spa"**
   - Bundle identifier: `com.prirodaspa.app`
   - Provisioning profile type: **App store**
3. **Save**

---

## ✅ Решение 2: Исправить текущий Shorebird Workflow

Если вы **используете Shorebird**:

### Шаг 1: Добавьте Shorebird Token

1. Найдите поле **"Shorebird token"**
2. Введите ваш Shorebird token
3. Если нет токена - получите на [shorebird.dev](https://shorebird.dev)

### Шаг 2: Исправьте Build Arguments

1. **iOS Build arguments:**
   - Измените: `release ios -t lib/main.dart`
   - На: `release ios -t lib/main.dart` (правильный формат для Shorebird)
   - Или: `release ios` (если не нужен target)

2. **Android Build arguments:**
   - Измените: `release android --target`
   - На: `release android -t lib/main.dart`
   - Или: `release android`

### Шаг 3: Настройте Code Signing

1. Перейдите на вкладку **"Code signing"** или **"Distribution"**
2. Настройте iOS code signing (как в Решении 1)

---

## 🔍 Исправление Build Arguments

### Для обычного Flutter (без Shorebird):

**iOS:**
```
--release
```
или
```
--release -t lib/main.dart
```

**Android:**
```
--release
```
или
```
--release -t lib/main.dart
```

### Для Shorebird:

**iOS:**
```
release ios -t lib/main.dart
```

**Android:**
```
release android -t lib/main.dart
```

---

## ⚠️ Важно

1. **Shorebird** - это сервис для OTA обновлений Flutter приложений
2. Если вы **НЕ используете Shorebird** - создайте обычный iOS workflow
3. **Build arguments** должны быть правильными для выбранного типа workflow

---

## 🎯 Рекомендуемое решение

### Если НЕ используете Shorebird:

1. **Создайте новый workflow:**
   - **"+"** → **Create workflow** → **"iOS"** (не Shorebird!)

2. **Настройте:**
   - Flutter version: `channel Stable`
   - Project path: `spa`
   - iOS Build arguments: `--release`
   - Android Build arguments: `--release`

3. **Настройте Code Signing:**
   - Automatic
   - App Store Connect API key: "Priroda Spa"
   - Bundle identifier: `com.prirodaspa.app`
   - Provisioning profile type: App store

4. **Save** и запустите сборку

---

## ✅ Чек-лист

Перед сохранением убедитесь:

- [ ] **Тип workflow:** iOS (не Shorebird, если не используете)
- [ ] **Flutter version:** Stable (не Shorebird default, если не используете)
- [ ] **Shorebird token:** Заполнен (только если используете Shorebird)
- [ ] **Project path:** `spa`
- [ ] **iOS Build arguments:** `--release` (для обычного Flutter)
- [ ] **Android Build arguments:** `--release` (для обычного Flutter)
- [ ] **Code signing:** Настроен (Automatic с API ключом)

---

**Главное:** Если не используете Shorebird - создайте обычный iOS workflow вместо Shorebird workflow!

