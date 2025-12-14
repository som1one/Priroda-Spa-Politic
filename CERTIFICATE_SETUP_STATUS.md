# ✅ Статус настройки сертификатов iOS

## 📋 Что создано:

### ✅ Файлы сертификатов:
1. **`private_key.pem`** - Приватный ключ (2048 бит)
2. **`CertificateSigningRequest.certSigningRequest`** - Запрос на сертификат (CSR)

### ✅ Конфигурация:
1. **`.gitignore`** - Настроен для игнорирования всех файлов сертификатов
   - ✅ `*.pem`, `*.p12`, `*.cer`, `*.certSigningRequest`, `*.mobileprovision`
   - ✅ `private_key.pem` и другие приватные ключи
   - ✅ Base64 файлы сертификатов

### ✅ Проверка:
- ✅ CSR файл содержит валидный запрос
- ✅ Приватный ключ создан правильно
- ✅ Оба файла игнорируются Git (не будут закоммичены)

---

## 🚀 Следующие шаги:

### 1. Загрузите CSR в Apple Developer Portal

1. Откройте [developer.apple.com/account](https://developer.apple.com/account)
2. **Certificates, Identifiers & Profiles** → **Certificates**
3. Нажмите **"+"** → **iOS Distribution** → **App Store and Ad Hoc**
4. Загрузите файл: `CertificateSigningRequest.certSigningRequest`
5. **Continue** → **Download** (скачайте `.cer` файл)

### 2. Конвертируйте .cer в .p12

После скачивания `.cer` файла от Apple, выполните в папке проекта:

```powershell
# Конвертируйте .cer в .pem
openssl x509 -inform DER -in certificate.cer -out certificate.pem

# Создайте .p12 файл (замените YOUR_PASSWORD на свой пароль)
openssl pkcs12 -export -out certificate.p12 -inkey private_key.pem -in certificate.pem -password pass:YOUR_PASSWORD
```

### 3. Создайте Provisioning Profile

1. **Certificates, Identifiers & Profiles** → **Profiles**
2. Нажмите **"+"** → **App Store** → **Continue**
3. Выберите **App ID:** `com.prirodaspa.app`
4. Выберите **Certificate** (созданный выше)
5. **Generate** → **Download** (`.mobileprovision` файл)

### 4. Конвертируйте в Base64 для GitHub

```powershell
# Для .p12
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Out-File -Encoding ASCII certificate_base64.txt

# Для .mobileprovision
[Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision")) | Out-File -Encoding ASCII profile_base64.txt
```

### 5. Добавьте в GitHub Secrets

GitHub → Settings → Secrets and variables → Actions → New repository secret:

- `APPLE_CERTIFICATE_BASE64` - содержимое `certificate_base64.txt`
- `APPLE_CERTIFICATE_PASSWORD` - пароль от `.p12` файла
- `APPLE_PROVISIONING_PROFILE_BASE64` - содержимое `profile_base64.txt`
- `KEYCHAIN_PASSWORD` - любой пароль (например, `temp_password`)

### 6. Запустите сборку

GitHub → Actions → **iOS Build** → Run workflow

---

## ⚠️ Важно:

1. **Не удаляйте `private_key.pem`** до создания `.p12` файла
2. **После создания `.p12`** можно удалить `private_key.pem` (но лучше сохранить резервную копию)
3. **Не коммитьте** файлы сертификатов в Git (они уже в `.gitignore`)
4. **Храните `.p12` и `.mobileprovision`** в безопасном месте

---

## 📝 Альтернатива (без сертификатов):

Если не хотите возиться с сертификатами, используйте **App Store Connect API**:
- См. `QUICK_START_IOS_WITHOUT_MAC.md`
- Не нужны сертификаты
- Не нужен Mac
- Работает автоматически

---

**Текущий статус:** ✅ Готово к загрузке CSR в Apple Developer Portal

