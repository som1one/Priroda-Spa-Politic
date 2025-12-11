# 🎯 Настройка iOS Workflow через UI Codemagic

## 🚨 Проблема

Workflow из `codemagic.yaml` не использует настройки code signing из UI. Нужно создать workflow через UI Codemagic.

---

## ✅ Решение: Создать Workflow через UI

### Шаг 1: Создайте новый Workflow

1. **Codemagic → Ваш проект → Workflows**
2. Нажмите **"+"** (Add workflow)
3. Выберите **"iOS"** или **"Flutter iOS"**

---

### Шаг 2: Настройте Build

1. **Working directory:**
   - Введите: `spa`
   - Это путь к Flutter проекту

2. **Flutter version:**
   - Выберите: `stable`

3. **Xcode version:**
   - Выберите: `latest`

---

### Шаг 3: Настройте Code Signing

**Это самый важный шаг!**

1. Найдите раздел **"Code signing"** или **"iOS code signing"**
2. Выберите **"Automatic"** (не Manual)
3. Заполните:
   - **App Store Connect API key:** Выберите "Priroda Spa" из списка
   - **Bundle identifier:** `com.prirodaspa.app`
   - **Provisioning profile type:** `App store` (не Development или Ad hoc)
4. **Save**

---

### Шаг 4: Настройте Build Command

1. Найдите раздел **"Build"** или **"Build commands"**
2. **Build command:**
   ```
   flutter build ipa --release
   ```
3. Или оставьте по умолчанию, если есть опция "Build iOS app"

---

### Шаг 5: Настройте Artifacts (опционально)

1. **Artifacts:**
   - `build/ios/ipa/*.ipa`

---

### Шаг 6: Сохраните и запустите

1. Нажмите **"Save"** или **"Save workflow"**
2. **Start new build**
3. Выберите новый workflow
4. Выберите ветку: `master` (или ваша ветка)
5. **Start build**

---

## 🔍 Проверка перед запуском

Убедитесь, что:

- [ ] **Bundle ID зарегистрирован:**
  - [developer.apple.com/account](https://developer.apple.com/account) → Identifiers
  - Должен быть: `com.prirodaspa.app`

- [ ] **App Store Connect API ключ настроен:**
  - Codemagic → Settings → Code signing → iOS code signing
  - Должен быть выбран: "Priroda Spa (Key: 84SR375827)"

- [ ] **Code signing: Automatic:**
  - В настройках workflow
  - App Store Connect API key выбран
  - Bundle identifier: `com.prirodaspa.app`
  - Provisioning profile type: App store

---

## ⚠️ Важно

1. **Не используйте yaml workflow для iOS code signing**
   - Лучше создать через UI
   - Code signing работает надежнее через UI

2. **Bundle ID должен совпадать везде:**
   - В проекте: `com.prirodaspa.app`
   - В Codemagic: `com.prirodaspa.app`
   - В Apple Developer Portal: `com.prirodaspa.app`

3. **Provisioning profile type: App store**
   - Не Development
   - Не Ad hoc
   - Только App store (для публикации)

---

## 🎯 Альтернатива: Исправить yaml workflow

Если хотите использовать yaml, нужно убедиться, что:

1. **Настройки code signing в UI правильные:**
   - Codemagic → Settings → Code signing → iOS code signing
   - Automatic
   - App Store Connect API key выбран
   - Bundle identifier: `com.prirodaspa.app`

2. **Workflow использует эти настройки:**
   - Но это не всегда работает с yaml

**Рекомендация:** Используйте UI workflow для iOS code signing!

---

## 📝 Пример настройки через UI

```
Workflow Name: iOS Release
Working directory: spa
Flutter version: stable
Xcode version: latest

Code signing:
  Method: Automatic
  App Store Connect API key: Priroda Spa
  Bundle identifier: com.prirodaspa.app
  Provisioning profile type: App store

Build command: flutter build ipa --release
```

---

## ✅ После настройки

После создания workflow через UI:

1. ✅ Codemagic автоматически создаст сертификаты
2. ✅ Создаст provisioning profile
3. ✅ Подпишет приложение
4. ✅ Соберет IPA файл

---

**Главное:** Создайте workflow через UI Codemagic с правильными настройками code signing - это решит все проблемы!

