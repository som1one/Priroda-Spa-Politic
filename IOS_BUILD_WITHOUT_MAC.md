# Сборка iOS без Mac

## 🎯 Варианты сборки iOS без физического Mac

У вас есть **3 основных варианта**:

1. ✅ **GitHub Actions** (бесплатно для публичных репозиториев)
2. ✅ **Codemagic** (бесплатный план: 500 минут/месяц)
3. ✅ **AppCircle** (бесплатный план)

---

## 🚀 Вариант 1: GitHub Actions (Рекомендуется)

### Преимущества:
- ✅ Бесплатно для публичных репозиториев
- ✅ 2000 минут/месяц для приватных репозиториев
- ✅ Уже настроен в вашем проекте
- ✅ Автоматическая сборка при push

### Настройка:

#### 1. Подготовка сертификатов

**Вам нужно:**
- Apple Developer Certificate (.p12)
- Provisioning Profile (.mobileprovision)

**Как получить:**

1. Войдите в [Apple Developer Portal](https://developer.apple.com/account)
2. **Certificates, Identifiers & Profiles**
3. Создайте:
   - **Certificate** (тип: iOS App Development или Distribution)
   - **App ID** (com.prirodaspa.app)
   - **Provisioning Profile** (для вашего App ID)

#### 2. Конвертация сертификатов в Base64

**На Mac или через онлайн-конвертер:**

```bash
# Конвертация сертификата
base64 -i certificate.p12 -o certificate_base64.txt

# Конвертация provisioning profile
base64 -i profile.mobileprovision -o profile_base64.txt
```

**Или используйте PowerShell (Windows):**

```powershell
# Сертификат
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Out-File "certificate_base64.txt"

# Provisioning Profile
[Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision")) | Out-File "profile_base64.txt"
```

#### 3. Добавление секретов в GitHub

1. Перейдите в ваш репозиторий на GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Добавьте следующие секреты:

   - `APPLE_CERTIFICATE_BASE64` - содержимое certificate_base64.txt
   - `APPLE_CERTIFICATE_PASSWORD` - пароль от .p12 файла
   - `APPLE_PROVISIONING_PROFILE_BASE64` - содержимое profile_base64.txt
   - `APPLE_TEAM_ID` - ваш Team ID (найти в Apple Developer Portal)

#### 4. Обновление workflow

Ваш файл `.github/workflows/ios-build.yml` уже настроен! Просто раскомментируйте секреты:

```yaml
env:
  APPLE_CERTIFICATE_BASE64: ${{ secrets.APPLE_CERTIFICATE_BASE64 }}
  APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
  APPLE_PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_PROVISIONING_PROFILE_BASE64 }}
```

#### 5. Запуск сборки

**Автоматически:**
- При push в `main` или `master`
- При создании Pull Request

**Вручную:**
1. Перейдите в **Actions** на GitHub
2. Выберите workflow **iOS Build**
3. Нажмите **Run workflow**

#### 6. Скачивание IPA

После успешной сборки:
1. Откройте завершенный workflow run
2. В разделе **Artifacts** скачайте `ios-ipa`
3. Распакуйте и получите `.ipa` файл

---

## 🎨 Вариант 2: Codemagic (Самый простой)

### Преимущества:
- ✅ Очень простой интерфейс
- ✅ Автоматическая настройка сертификатов
- ✅ Прямая загрузка в TestFlight
- ✅ Бесплатно: 500 минут/месяц

### Настройка:

#### 1. Регистрация

1. Перейдите на [codemagic.io](https://codemagic.io)
2. Войдите через GitHub
3. Подключите ваш репозиторий

#### 2. Настройка проекта

1. Выберите ваш репозиторий
2. Выберите **iOS** как платформу
3. Codemagic автоматически определит Flutter проект

#### 3. Настройка сертификатов

**Вариант A: Автоматически (рекомендуется)**
1. В настройках проекта → **Code signing**
2. Войдите в Apple Developer аккаунт
3. Codemagic автоматически создаст и настроит сертификаты

**Вариант B: Вручную**
1. Загрузите сертификат и provisioning profile
2. Укажите Bundle ID: `com.prirodaspa.app`

#### 4. Настройка workflow

Ваш файл `codemagic.yaml` уже настроен! Просто:

1. В Codemagic UI выберите **Use configuration file**
2. Укажите путь: `codemagic.yaml`
3. Обновите email в конфигурации:
   ```yaml
   email:
     recipients:
       - ваш-email@example.com
   ```

#### 5. Запуск сборки

1. Нажмите **Start new build**
2. Выберите ветку (например, `main`)
3. Нажмите **Start build**

#### 6. Автоматическая загрузка в TestFlight

Раскомментируйте в `codemagic.yaml`:

```yaml
app_store_connect:
  auth:
    issuer_id: $APP_STORE_ISSUER_ID
    key_id: $APP_STORE_KEY_ID
    key: $APP_STORE_PRIVATE_KEY
  submit_to_testflight: true
```

**Для получения App Store Connect API ключа:**
1. [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access**
2. **Keys** → **Generate API Key**
3. Сохраните:
   - Issuer ID
   - Key ID
   - Скачайте .p8 файл (приватный ключ)
4. Добавьте в Codemagic как секреты

---

## 🔧 Вариант 3: AppCircle

### Преимущества:
- ✅ Бесплатный план
- ✅ Простой интерфейс
- ✅ Автоматическая настройка

### Настройка:

1. Регистрация на [appcircle.io](https://appcircle.io)
2. Подключите GitHub репозиторий
3. Выберите **iOS** workflow
4. Настройте сертификаты (автоматически или вручную)
5. Запустите сборку

---

## 📋 Пошаговая инструкция для GitHub Actions

### Шаг 1: Получение сертификатов

**Если у вас нет Mac, используйте:**

1. **App Store Connect API Key** (рекомендуется)
   - Не требует .p12 сертификата
   - Работает только для загрузки в App Store/TestFlight

2. **Виртуальный Mac** (MacinCloud, MacStadium)
   - Арендуйте Mac на час
   - Создайте сертификаты через Xcode

3. **Попросите коллегу с Mac**
   - Создайте сертификаты на его Mac
   - Экспортируйте .p12 и provisioning profile

### Шаг 2: Создание ExportOptions.plist

Создайте файл `spa/ios/ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
```

Замените `YOUR_TEAM_ID` на ваш Team ID.

### Шаг 3: Обновление workflow

Обновите `.github/workflows/ios-build.yml`:

```yaml
- name: Setup certificates
  env:
    BUILD_CERTIFICATE_BASE64: ${{ secrets.APPLE_CERTIFICATE_BASE64 }}
    P12_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
    KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
    PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_PROVISIONING_PROFILE_BASE64 }}
  run: |
    # Создание keychain
    security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
    security set-keychain-settings -t 3600 -u build.keychain

    # Импорт сертификата
    echo "$BUILD_CERTIFICATE_BASE64" | base64 --decode > certificate.p12
    security import certificate.p12 -k build.keychain -P "$P12_PASSWORD" -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" build.keychain

    # Импорт provisioning profile
    echo "$PROVISIONING_PROFILE_BASE64" | base64 --decode > profile.mobileprovision
    mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
    cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
```

### Шаг 4: Запуск

1. Закоммитьте изменения
2. Запушьте в репозиторий
3. GitHub Actions автоматически запустит сборку

---

## 🎯 Рекомендация

**Для начала используйте Codemagic:**
- ✅ Самый простой способ
- ✅ Автоматическая настройка сертификатов
- ✅ Прямая загрузка в TestFlight
- ✅ Хорошая документация

**После освоения переходите на GitHub Actions:**
- ✅ Бесплатно для публичных репозиториев
- ✅ Полный контроль над процессом
- ✅ Интеграция с вашим workflow

---

## ⚠️ Важные замечания

1. **Apple Developer аккаунт обязателен**
   - Нужна активная подписка ($99/год)
   - Без неё нельзя подписать приложение

2. **Bundle Identifier должен быть уникальным**
   - Уже настроен: `com.prirodaspa.app`
   - Проверьте в Apple Developer Portal

3. **GoogleService-Info.plist**
   - Должен быть в `spa/ios/Runner/`
   - Скачайте из Firebase Console

4. **Минимальная версия iOS**
   - Проверьте в `spa/ios/Podfile`
   - Рекомендуется: iOS 12.0+

---

## 🚀 Быстрый старт (Codemagic)

1. Зарегистрируйтесь на [codemagic.io](https://codemagic.io)
2. Подключите GitHub репозиторий
3. Выберите **iOS** workflow
4. Войдите в Apple Developer аккаунт
5. Нажмите **Start build**
6. Готово! IPA файл будет готов через 10-15 минут

---

## 📞 Нужна помощь?

Если возникнут проблемы:
1. Проверьте логи сборки
2. Убедитесь, что все секреты добавлены
3. Проверьте Bundle ID в Apple Developer Portal
4. Убедитесь, что GoogleService-Info.plist на месте
