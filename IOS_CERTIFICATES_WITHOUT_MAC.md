# 🍎 Получение iOS сертификатов без Mac

## 🚨 Проблема

Для создания `.p12` файла обычно нужен Mac с Keychain Access. Но есть альтернативы!

---

## ✅ Вариант 1: Использовать OpenSSL на Windows (Рекомендуется)

OpenSSL может работать с сертификатами на Windows.

### Шаг 1: Установите OpenSSL

**Скачайте:**
- [OpenSSL для Windows](https://slproweb.com/products/Win32OpenSSL.html)
- Или через Chocolatey: `choco install openssl`

### Шаг 2: Создайте приватный ключ и CSR

**Выполните в папке проекта** (например, `D:\PycharmProjects\Spa`):

```powershell
# Перейдите в папку проекта (если еще не там)
cd D:\PycharmProjects\Spa

# Создайте приватный ключ
openssl genrsa -out private_key.pem 2048

# Создайте Certificate Signing Request (CSR)
openssl req -new -key private_key.pem -out CertificateSigningRequest.certSigningRequest -subj "/emailAddress=farm49595@gmail.com/CN=Priroda Spa/C=RU"
```

**Важно:** 
- Файлы создадутся в текущей папке (`D:\PycharmProjects\Spa`)
- После использования **удалите** `private_key.pem` (храните только `.p12` файл)

### Шаг 3: Загрузите CSR в Apple Developer Portal

1. [developer.apple.com/account](https://developer.apple.com/account) → Certificates
2. "+" → iOS Distribution → App Store and Ad Hoc
3. Загрузите `CertificateSigningRequest.certSigningRequest`
4. Скачайте `.cer` файл

### Шаг 4: Конвертируйте .cer в .p12

```powershell
# Конвертируйте .cer в .pem
openssl x509 -inform DER -in certificate.cer -out certificate.pem

# Создайте .p12 из .pem и приватного ключа
openssl pkcs12 -export -out certificate.p12 -inkey private_key.pem -in certificate.pem -password pass:YOUR_PASSWORD
```

**Готово!** Теперь у вас есть `certificate.p12` файл.

---

## ✅ Вариант 2: Попросить кого-то с Mac

Самый простой и безопасный способ.

### Что нужно попросить:

1. **Создать CSR на Mac:**
   - Keychain Access → Certificate Assistant → Request a Certificate
   - Сохранить `.certSigningRequest` файл

2. **Загрузить CSR в Apple Developer Portal:**
   - Вы делаете это сами
   - Скачиваете `.cer` файл

3. **Конвертировать .cer в .p12 на Mac:**
   - Открыть `.cer` в Keychain Access
   - Экспортировать как `.p12` с паролем
   - Отправить вам `.p12` файл

**Безопасно:** Человек с Mac не видит ваш Apple Developer аккаунт, только помогает с конвертацией.

---

## ✅ Вариант 3: Использовать онлайн-сервисы (Не рекомендуется)

⚠️ **ВНИМАНИЕ:** Небезопасно! Не загружайте приватные ключи на сторонние сервисы.

Если все же хотите попробовать:
- [Online CSR Generator](https://www.sslshopper.com/csr-generator.html) - только для CSR
- Некоторые сервисы могут конвертировать .cer в .p12, но это рискованно

**Лучше не использовать** для production приложений.

---

## ✅ Вариант 4: Использовать App Store Connect API (Без сертификатов!) ⭐ РЕКОМЕНДУЕТСЯ

Можно использовать автоматическую подпись через API ключ. **Это самый простой вариант без Mac!**

### Настройка для GitHub Actions:

1. **Создайте App Store Connect API ключ:**
   - [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → Users and Access → Keys
   - "+" → App Manager (или Admin)
   - Скачайте `.p8` файл
   - Запомните **Issuer ID** и **Key ID**

2. **Добавьте в GitHub Secrets:**
   - `APP_STORE_ISSUER_ID` - Issuer ID (например: `4fbfcedf-2756-4b8e-8fc3-b17978e9532a`)
   - `APP_STORE_KEY_ID` - Key ID (например: `84SR375827`)
   - `APP_STORE_PRIVATE_KEY` - содержимое `.p8` файла (весь текст, включая `-----BEGIN PRIVATE KEY-----` и `-----END PRIVATE KEY-----`)

3. **Используйте workflow `ios-build-api.yml`:**
   - GitHub → Actions → iOS Build (App Store Connect API) → Run workflow

**Готово!** Не нужны сертификаты, не нужен Mac - все работает автоматически через API!

### Преимущества:
- ✅ Не нужен Mac
- ✅ Не нужны сертификаты
- ✅ Автоматическая подпись
- ✅ Работает сразу после настройки API ключа

---

## ✅ Вариант 5: Использовать Codemagic с Manual Signing

Если у вас уже есть `.p12` и `.mobileprovision` (полученные любым способом):

1. **Codemagic → Settings → Code signing → iOS code signing**
2. Выберите **"Manual"**
3. Загрузите:
   - Certificate: `.p12` файл
   - Certificate password: пароль
   - Provisioning profile: `.mobileprovision` файл
4. **Save**

Codemagic сам настроит все остальное.

---

## 🎯 Рекомендуемый порядок действий

### ⭐ ЛУЧШИЙ ВАРИАНТ (без Mac):
→ **Вариант 4** (App Store Connect API) - **НЕ НУЖНЫ СЕРТИФИКАТЫ!**

### Если есть доступ к Mac (друг/коллега):
→ **Вариант 2** (самый простой и безопасный)

### Если нет Mac, но есть OpenSSL:
→ **Вариант 1** (работает на Windows)

### Если уже есть сертификаты:
→ **Вариант 5** (Codemagic Manual Signing) или GitHub Actions с сертификатами

---

## 📝 Пошаговая инструкция: OpenSSL на Windows

### 1. Установите OpenSSL

```powershell
# Через Chocolatey (если установлен)
choco install openssl

# Или скачайте с https://slproweb.com/products/Win32OpenSSL.html
# Установите в C:\OpenSSL-Win64
```

### 2. Добавьте OpenSSL в PATH

```powershell
# Временно для текущей сессии
$env:PATH += ";C:\OpenSSL-Win64\bin"

# Или добавьте в системные переменные PATH
```

### 3. Создайте приватный ключ

```powershell
openssl genrsa -out private_key.pem 2048
```

### 4. Создайте CSR

```powershell
openssl req -new -key private_key.pem -out CertificateSigningRequest.certSigningRequest -subj "/emailAddress=your@email.com/CN=Your Name/C=RU"
```

**Замените:**
- `your@email.com` - ваш email
- `Your Name` - ваше имя
- `C=RU` - код страны (RU для России)

### 5. Загрузите CSR в Apple Developer Portal

1. [developer.apple.com/account](https://developer.apple.com/account) → Certificates
2. "+" → iOS Distribution → App Store and Ad Hoc
3. Загрузите `CertificateSigningRequest.certSigningRequest`
4. **Continue** → **Download** (`.cer` файл)

### 6. Конвертируйте .cer в .p12

```powershell
# Конвертируйте .cer в .pem
openssl x509 -inform DER -in certificate.cer -out certificate.pem

# Создайте .p12 (замените YOUR_PASSWORD на свой пароль)
openssl pkcs12 -export -out certificate.p12 -inkey private_key.pem -in certificate.pem -password pass:YOUR_PASSWORD
```

### 7. Конвертируйте в Base64 для GitHub

```powershell
# Для .p12
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Out-File -Encoding ASCII certificate_base64.txt

# Для .mobileprovision (создайте в Apple Developer Portal)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision")) | Out-File -Encoding ASCII profile_base64.txt
```

---

## 🔐 Важно: Безопасность

1. **Храните приватные ключи в безопасности:**
   - Не загружайте `.pem` или `.p12` в публичные репозитории
   - Используйте только GitHub Secrets

2. **Удалите временные файлы:**
   ```powershell
   Remove-Item private_key.pem, certificate.pem, CertificateSigningRequest.certSigningRequest
   ```

3. **Не делитесь сертификатами:**
   - Каждый разработчик должен иметь свой сертификат
   - Или используйте общий сертификат только в безопасном месте

---

## ⚠️ Решение проблем

### Ошибка: "openssl: command not found"

**Решение:**
- Установите OpenSSL
- Добавьте в PATH: `C:\OpenSSL-Win64\bin`

### Ошибка: "unable to load certificate"

**Решение:**
- Проверьте формат файла (должен быть `.cer` или `.pem`)
- Убедитесь, что файл не поврежден

### Ошибка: "invalid password"

**Решение:**
- Проверьте пароль от `.p12`
- Убедитесь, что используете правильный пароль в GitHub Secrets

---

**Рекомендация:** Если есть возможность, используйте **Вариант 2** (попросить кого-то с Mac) - это самый простой и безопасный способ. Если нет - используйте **Вариант 1** (OpenSSL на Windows).

