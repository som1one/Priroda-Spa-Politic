# 🔧 Установка OpenSSL на Windows

## ✅ Вариант 1: Установка через установщик (Рекомендуется)

### Шаг 1: Скачайте OpenSSL

1. Откройте [https://slproweb.com/products/Win32OpenSSL.html](https://slproweb.com/products/Win32OpenSSL.html)
2. Скачайте **Win64 OpenSSL v3.x.x** (Light или Full версия)
   - **Light** - минимальная версия (достаточно)
   - **Full** - полная версия с документацией

### Шаг 2: Установите OpenSSL

1. Запустите установщик
2. Выберите **"Copy OpenSSL DLLs to"** → **"The OpenSSL binaries (/bin) directory"**
3. Установите в `C:\OpenSSL-Win64` (по умолчанию)
4. **Install**

### Шаг 3: Добавьте в PATH

**Временно (для текущей сессии PowerShell):**
```powershell
$env:PATH += ";C:\OpenSSL-Win64\bin"
```

**Постоянно (для всех сессий):**
1. Нажмите `Win + R` → введите `sysdm.cpl` → Enter
2. **Дополнительно** → **Переменные среды**
3. В **"Системные переменные"** найдите `Path` → **Изменить**
4. **Создать** → введите `C:\OpenSSL-Win64\bin`
5. **OK** → **OK** → **OK**

### Шаг 4: Проверьте установку

Откройте **новый** PowerShell и выполните:
```powershell
openssl version
```

Должно показать версию OpenSSL.

---

## ✅ Вариант 2: Установка через Chocolatey

Если хотите использовать менеджер пакетов:

### Шаг 1: Установите Chocolatey

Откройте PowerShell **от имени администратора** и выполните:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Шаг 2: Установите OpenSSL

```powershell
choco install openssl
```

### Шаг 3: Проверьте установку

```powershell
openssl version
```

---

## ✅ Вариант 3: Использовать Git Bash (если установлен Git)

Если у вас установлен Git, OpenSSL уже может быть доступен через Git Bash:

1. Откройте **Git Bash** (не PowerShell)
2. Проверьте:
```bash
openssl version
```

Если работает - используйте Git Bash для всех команд OpenSSL.

---

## 🚀 После установки OpenSSL

Теперь вы можете использовать команды из `IOS_CERTIFICATES_WITHOUT_MAC.md`:

```powershell
# Создайте приватный ключ
openssl genrsa -out private_key.pem 2048

# Создайте CSR
openssl req -new -key private_key.pem -out CertificateSigningRequest.certSigningRequest -subj "/emailAddress=your@email.com/CN=Your Name/C=RU"

# После получения .cer от Apple:
openssl x509 -inform DER -in certificate.cer -out certificate.pem

# Создайте .p12
openssl pkcs12 -export -out certificate.p12 -inkey private_key.pem -in certificate.pem -password pass:YOUR_PASSWORD
```

---

## ⚠️ Важно

После добавления OpenSSL в PATH:
- **Закройте и откройте PowerShell заново** (чтобы PATH обновился)
- Или выполните: `$env:PATH += ";C:\OpenSSL-Win64\bin"` в текущей сессии

---

## 💡 Рекомендация

Если OpenSSL нужен только для iOS сертификатов, лучше использовать **Вариант 1 (App Store Connect API)** - не нужен OpenSSL вообще!

См. `QUICK_START_IOS_WITHOUT_MAC.md` для инструкций.

