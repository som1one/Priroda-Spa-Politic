# 🔐 Исправление ошибки code signing в Codemagic

## 🚨 Проблема

Ошибка: `No valid code signing certificates were found`
- Codemagic не может найти сертификаты для подписи iOS приложения
- Используется метод "ad-hoc" вместо "app-store"
- Не найдены provisioning profiles

---

## ✅ Решение: Настроить Automatic Code Signing в UI

Codemagic должен автоматически создавать сертификаты, но для этого нужно правильно настроить в UI.

### Шаг 1: Проверьте настройки iOS Code Signing

1. **В Codemagic → Ваш проект → Settings**
2. **Code signing** → **iOS code signing**
3. Убедитесь, что:
   - ✅ **Метод:** "Automatic" (выбран)
   - ✅ **App Store Connect API key:** "Priroda Spa (Key: 84SR375827)" (выбран)
   - ✅ **Provisioning profile type:** "App store" (выбран)
   - ✅ **Bundle identifier:** `com.prirodaspa.app` (выбран)

### Шаг 2: Проверьте, что Bundle ID зарегистрирован

Убедитесь, что Bundle ID `com.prirodaspa.app` зарегистрирован в Apple Developer Portal:

1. [developer.apple.com/account](https://developer.apple.com/account)
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. Проверьте, что есть App ID: `com.prirodaspa.app`

Если нет - зарегистрируйте (см. `REGISTER_BUNDLE_ID.md`)

---

## 🔧 Альтернативное решение: Использовать UI Workflow

Если workflow из yaml не работает, настройте через UI:

### Шаг 1: Создайте новый workflow через UI

1. **Codemagic → Ваш проект → Workflows**
2. **"+"** → **Create workflow**
3. Выберите **"iOS"**

### Шаг 2: Настройте Code Signing

1. В настройках workflow найдите **"Code signing"**
2. Выберите **"Automatic"**
3. Заполните:
   - **App Store Connect API key:** Выберите "Priroda Spa"
   - **Bundle identifier:** `com.prirodaspa.app`
   - **Provisioning profile type:** App store
4. **Save**

### Шаг 3: Настройте Build

1. **Working directory:** `spa`
2. **Flutter version:** stable
3. **Build command:** `flutter build ipa --release`

---

## 📝 Обновление codemagic.yaml (опционально)

Если хотите использовать yaml, можно добавить явную настройку, но обычно UI настройки достаточно.

---

## ⚠️ Важно

1. **Automatic code signing** должен быть включен
2. **App Store Connect API key** должен быть выбран
3. **Bundle ID** должен быть зарегистрирован в Apple Developer Portal
4. **Provisioning profile type** должен быть "App store" (не "Development" или "Ad hoc")

---

## 🔍 Проверка Team ID

Если в логах видно "Team Id: " (пустое), нужно:

1. **В Apple Developer Portal:**
   - [developer.apple.com/account](https://developer.apple.com/account)
   - **Membership** → Скопируйте **Team ID**

2. **В Codemagic:**
   - Settings → iOS code signing
   - Если есть поле "Team ID" - вставьте его
   - Обычно Codemagic определяет автоматически через API ключ

---

## 🎯 Рекомендуемый порядок действий

1. ✅ **Проверьте настройки iOS code signing в UI:**
   - Automatic
   - App Store Connect API key выбран
   - Bundle ID выбран
   - Provisioning profile type: App store

2. ✅ **Убедитесь, что Bundle ID зарегистрирован:**
   - [developer.apple.com/account](https://developer.apple.com/account) → Identifiers
   - Должен быть `com.prirodaspa.app`

3. ✅ **Запустите сборку заново:**
   - Codemagic автоматически создаст сертификаты
   - Создаст provisioning profile
   - Подпишет приложение

---

## 💡 Если всё еще не работает

### Вариант 1: Создайте сертификаты вручную

1. **Apple Developer Portal:**
   - Certificates → Create certificate → iOS Distribution
   - Скачайте сертификат

2. **Codemagic:**
   - Settings → Code signing → Manual
   - Загрузите сертификат и provisioning profile

### Вариант 2: Используйте Xcode Cloud или другой сервис

Если Codemagic не работает, можно использовать:
- Xcode Cloud (если есть Mac)
- GitHub Actions с Mac runner
- Другой CI/CD сервис

---

## ✅ Чек-лист

Перед запуском сборки убедитесь:

- [ ] iOS code signing настроен в UI Codemagic
- [ ] Метод: Automatic
- [ ] App Store Connect API key выбран
- [ ] Bundle ID `com.prirodaspa.app` выбран
- [ ] Provisioning profile type: App store
- [ ] Bundle ID зарегистрирован в Apple Developer Portal
- [ ] App Store Connect API ключ правильно настроен

---

**Главное:** Убедитесь, что в UI Codemagic настроен **Automatic code signing** с правильным API ключом и Bundle ID!

