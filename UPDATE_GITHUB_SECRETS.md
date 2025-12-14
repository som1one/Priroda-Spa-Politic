# 🔐 Обновление секретов в GitHub

## Новый пароль: `prirodaspa2018`

### ⚡ Быстрое решение:

**Просто обновите пароль в GitHub Secrets - это все, что нужно!**

---

### Что нужно сделать:

1. **GitHub → Settings → Security → Secrets and variables → Actions**

2. **Обновите секрет `APPLE_CERTIFICATE_PASSWORD`:**
   - Найдите `APPLE_CERTIFICATE_PASSWORD`
   - Нажмите на иконку редактирования (карандаш)
   - Введите новый пароль: `prirodaspa2018`
   - **Update secret**

3. **Проверьте другие секреты (должны быть уже настроены):**
   - `APPLE_CERTIFICATE_BASE64` - должен быть актуальным
   - `APPLE_PROVISIONING_PROFILE_BASE64` - должен быть актуальным
   - `KEYCHAIN_PASSWORD` - любой пароль (например, `temp_password`)

---

## ⚠️ Если нужно пересоздать .p12

Если нужно пересоздать `.p12` с новым паролем (нужен OpenSSL):

1. Установите OpenSSL (см. инструкцию выше)
2. Выполните:
   ```powershell
   openssl x509 -inform DER -in ios_distribution.cer -out certificate.pem
   openssl pkcs12 -export -out certificate.p12 -inkey private_key.pem -in certificate.pem -password pass:prirodaspa2018
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Out-File -Encoding ASCII certificate_base64.txt
   ```
3. Обновите `APPLE_CERTIFICATE_BASE64` в GitHub

---

**После обновления секрета `APPLE_CERTIFICATE_PASSWORD` на `prirodaspa2018`, workflow должен пройти успешно!**

