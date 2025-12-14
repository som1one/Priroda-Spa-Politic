# 🚀 Настройка GitHub Actions для iOS сборки

## 📋 Что нужно сделать

1. Создать сертификаты в Apple Developer Portal
2. Конвертировать в base64
3. Добавить в GitHub Secrets
4. Запустить workflow

---

## 🔐 Шаг 1: Создание сертификатов

### 1.1. Создайте Distribution Certificate

1. Войдите в [developer.apple.com/account](https://developer.apple.com/account)
2. **Certificates, Identifiers & Profiles** → **Certificates**
3. Нажмите **"+"** → **iOS Distribution** → **App Store and Ad Hoc**
4. Следуйте инструкциям:
   - Откройте **Keychain Access** на Mac
   - **Certificate Assistant** → **Request a Certificate From a Certificate Authority**
   - Введите email и имя
   - Сохраните `.certSigningRequest` файл
   - Загрузите его в Apple Developer Portal
5. **Скачайте сертификат** (`.cer` файл)

### 1.2. Конвертируйте сертификат в .p12

**На Mac:**

1. Откройте `.cer` файл (дважды кликните)
2. Он откроется в **Keychain Access**
3. Найдите сертификат в **"My Certificates"**
4. **Правый клик** → **Export "..."** → **Personal Information Exchange (.p12)**
5. Введите **пароль** для .p12 файла (запомните его!)
6. Сохраните как `certificate.p12`

### 1.3. Создайте Provisioning Profile

1. **Certificates, Identifiers & Profiles** → **Profiles**
2. Нажмите **"+"** → **App Store** → **Continue**
3. Выберите **App ID:** `com.prirodaspa.app`
4. Выберите **Certificate** (созданный выше)
5. **Generate** → **Download** (`.mobileprovision` файл)

---

## 🔑 Шаг 2: Конвертация в Base64

### 2.1. Конвертируйте .p12 в base64

**На Mac/Linux:**
```bash
base64 -i certificate.p12 -o certificate_base64.txt
```

**На Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Out-File -Encoding ASCII certificate_base64.txt
```

**Или онлайн:**
- [base64encode.org](https://www.base64encode.org/)
- Загрузите `.p12` файл
- Скопируйте результат

### 2.2. Конвертируйте .mobileprovision в base64

**На Mac/Linux:**
```bash
base64 -i profile.mobileprovision -o profile_base64.txt
```

**На Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision")) | Out-File -Encoding ASCII profile_base64.txt
```

---

## 🔐 Шаг 3: Добавление в GitHub Secrets

1. Откройте ваш репозиторий на GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Нажмите **"New repository secret"**

### Добавьте 4 секрета:

#### 1. `APPLE_CERTIFICATE_BASE64`
- **Name:** `APPLE_CERTIFICATE_BASE64`
- **Value:** Содержимое `certificate_base64.txt` (весь текст, включая переносы строк)

#### 2. `APPLE_CERTIFICATE_PASSWORD`
- **Name:** `APPLE_CERTIFICATE_PASSWORD`
- **Value:** Пароль от `.p12` файла (который вы вводили при экспорте)

#### 3. `APPLE_PROVISIONING_PROFILE_BASE64`
- **Name:** `APPLE_PROVISIONING_PROFILE_BASE64`
- **Value:** Содержимое `profile_base64.txt` (весь текст)

#### 4. `KEYCHAIN_PASSWORD` (опционально)
- **Name:** `KEYCHAIN_PASSWORD`
- **Value:** Любой пароль (например, `temp_password`)
- Если не добавите, будет использован `temp_password`

---

## 🚀 Шаг 4: Запуск сборки

### Вариант 1: Автоматический запуск

Workflow запустится автоматически при:
- Push в ветку `main` или `master`
- Pull Request в `main` или `master`

### Вариант 2: Ручной запуск

1. Откройте **Actions** в GitHub
2. Выберите **"iOS Build"** workflow
3. Нажмите **"Run workflow"**
4. Выберите ветку (обычно `main`)
5. Нажмите **"Run workflow"**

---

## 📦 Шаг 5: Скачивание IPA

После успешной сборки:

1. Откройте **Actions** → выберите последний workflow run
2. Прокрутите вниз до **"Artifacts"**
3. Нажмите **"ios-ipa"**
4. Скачайте `.ipa` файл

---

## ⚠️ Важные моменты

### ✅ Проверьте перед запуском:

1. **Bundle ID зарегистрирован:**
   - [developer.apple.com/account](https://developer.apple.com/account) → Identifiers
   - Должен быть: `com.prirodaspa.app`

2. **Сертификат действителен:**
   - Certificates → проверьте, что сертификат не истек

3. **Provisioning Profile правильный:**
   - Profiles → проверьте, что профиль для **App Store**
   - Bundle ID: `com.prirodaspa.app`

4. **Base64 кодирование:**
   - Убедитесь, что в base64 нет лишних пробелов
   - Скопируйте весь текст из файла

---

## 🐛 Решение проблем

### Ошибка: "No valid code signing certificates were found"

**Решение:**
1. Проверьте, что `APPLE_CERTIFICATE_BASE64` добавлен правильно
2. Убедитесь, что пароль от `.p12` правильный
3. Проверьте, что сертификат не истек

### Ошибка: "Provisioning profile not found"

**Решение:**
1. Проверьте, что `APPLE_PROVISIONING_PROFILE_BASE64` добавлен
2. Убедитесь, что Bundle ID в профиле: `com.prirodaspa.app`
3. Проверьте, что профиль для **App Store** (не Development)

### Ошибка: "Bundle identifier mismatch"

**Решение:**
1. Проверьте `Info.plist`: `CFBundleIdentifier` должен быть `com.prirodaspa.app`
2. Проверьте `project.pbxproj`: `PRODUCT_BUNDLE_IDENTIFIER` должен быть `com.prirodaspa.app`

---

## 📝 Чеклист

- [ ] Создан Distribution Certificate в Apple Developer Portal
- [ ] Сертификат экспортирован в `.p12` с паролем
- [ ] Создан App Store Provisioning Profile
- [ ] `.p12` конвертирован в base64
- [ ] `.mobileprovision` конвертирован в base64
- [ ] `APPLE_CERTIFICATE_BASE64` добавлен в GitHub Secrets
- [ ] `APPLE_CERTIFICATE_PASSWORD` добавлен в GitHub Secrets
- [ ] `APPLE_PROVISIONING_PROFILE_BASE64` добавлен в GitHub Secrets
- [ ] Bundle ID зарегистрирован: `com.prirodaspa.app`
- [ ] Workflow запущен и успешно собрал IPA

---

**Готово!** После настройки GitHub Actions будет автоматически собирать iOS приложение при каждом push в main ветку.

