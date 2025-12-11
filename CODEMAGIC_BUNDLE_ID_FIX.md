# 🔧 Исправление Bundle ID и Code Signing в Codemagic

## 🚨 Проблема

В логах видно:
- `Archiving com.example.spa...` - неправильный Bundle ID
- `Method: ad-hoc` - должно быть `app-store`
- `Team Id: ` - пустое
- `Signing Style: manual` - должно быть `automatic`

---

## ✅ Решение 1: Проверьте Bundle ID в проекте

Bundle ID в проекте правильный (`com.prirodaspa.app`), но Codemagic может использовать другой.

### Проверьте в Xcode проекте:

1. Откройте `spa/ios/Runner.xcworkspace` в Xcode (если есть Mac)
2. Выберите проект **Runner** → Target **Runner**
3. **Signing & Capabilities** → Проверьте **Bundle Identifier**
4. Должно быть: `com.prirodaspa.app`

### Или проверьте в файлах:

```bash
# Проверьте project.pbxproj
grep -r "PRODUCT_BUNDLE_IDENTIFIER" spa/ios/Runner.xcodeproj/project.pbxproj
```

Должно быть: `com.prirodaspa.app`

---

## ✅ Решение 2: Настройте Code Signing в UI Codemagic

**Важно:** Workflow из yaml может не использовать настройки code signing из UI!

### Шаг 1: Проверьте настройки в UI

1. **Codemagic → Ваш проект → Settings**
2. **Code signing** → **iOS code signing**
3. Убедитесь:
   - ✅ **Метод:** "Automatic"
   - ✅ **App Store Connect API key:** "Priroda Spa" (выбран)
   - ✅ **Bundle identifier:** `com.prirodaspa.app` (выбран)
   - ✅ **Provisioning profile type:** "App store"

### Шаг 2: Используйте UI Workflow вместо yaml

Если workflow из yaml не работает:

1. **Codemagic → Workflows**
2. **"+"** → **Create workflow**
3. Выберите **"iOS"**
4. Настройте:
   - **Working directory:** `spa`
   - **Code signing:** Automatic (с API ключом)
   - **Bundle identifier:** `com.prirodaspa.app`
   - **Provisioning profile type:** App store
5. **Save**

---

## ✅ Решение 3: Обновите codemagic.yaml

Можно попробовать явно указать настройки, но обычно лучше использовать UI.

---

## 🔍 Почему "com.example.spa" в логах?

Возможные причины:
1. Где-то в настройках Xcode указан старый Bundle ID
2. Codemagic использует дефолтные настройки
3. Неправильно настроен code signing

### Проверьте:

```bash
# Проверьте все упоминания Bundle ID
grep -r "com.example" spa/ios/
grep -r "example.spa" spa/ios/
```

Если найдете - замените на `com.prirodaspa.app`

---

## 🎯 Рекомендуемое решение

### Вариант 1: Использовать UI Workflow (Рекомендуется)

1. **Codemagic → Workflows → "+" → Create workflow**
2. Выберите **"iOS"**
3. Настройте:
   - **Working directory:** `spa`
   - **Code signing:** Automatic
   - **App Store Connect API key:** "Priroda Spa"
   - **Bundle identifier:** `com.prirodaspa.app`
   - **Provisioning profile type:** App store
4. **Build command:** `flutter build ipa --release`
5. **Save** и запустите сборку

### Вариант 2: Исправить yaml workflow

Если хотите использовать yaml, нужно убедиться, что:
- Настройки code signing в UI правильные
- Workflow использует эти настройки

Но лучше использовать UI workflow для iOS code signing.

---

## ⚠️ Важно

1. **Bundle ID должен совпадать:**
   - В проекте: `com.prirodaspa.app`
   - В Codemagic UI: `com.prirodaspa.app`
   - В Apple Developer Portal: `com.prirodaspa.app`

2. **Code signing должен быть Automatic:**
   - В UI Codemagic выберите "Automatic"
   - Выберите App Store Connect API key
   - Codemagic автоматически создаст сертификаты

3. **Provisioning profile type:** App store (не Development или Ad hoc)

---

## ✅ Чек-лист

Перед запуском сборки:

- [ ] Bundle ID в проекте: `com.prirodaspa.app`
- [ ] Bundle ID в Codemagic UI: `com.prirodaspa.app`
- [ ] Bundle ID зарегистрирован в Apple Developer Portal
- [ ] Code signing: Automatic
- [ ] App Store Connect API key выбран в UI
- [ ] Provisioning profile type: App store
- [ ] Working directory: `spa`

---

**Главное:** Используйте UI Workflow для iOS code signing - это проще и надежнее, чем настройка через yaml!

