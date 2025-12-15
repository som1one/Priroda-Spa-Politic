# 👀 Как посмотреть GitHub Secrets

## 📍 Путь к секретам:

1. **Откройте ваш репозиторий на GitHub:**
   - `https://github.com/som1one/SpaApp`

2. **Перейдите в Settings:**
   - Нажмите на вкладку **"Settings"** (вверху, справа)

3. **Откройте Secrets:**
   - В левом меню найдите раздел **"Security"**
   - Внутри "Security" нажмите **"Secrets and variables"**
   - Выберите **"Actions"**

4. **Просмотр секретов:**
   - Вы увидите список всех секретов
   - **Названия** секретов видны полностью
   - **Значения** скрыты (показаны как `***`)

---

## 🔍 Что вы увидите:

### Repository secrets:
- `APPLE_CERTIFICATE_BASE64` - значение скрыто (***)
- `APPLE_CERTIFICATE_PASSWORD` - значение скрыто (***)
- `APPLE_PROVISIONING_PROFILE_BASE64` - значение скрыто (***)
- `KEYCHAIN_PASSWORD` - значение скрыто (***)

---

## ⚠️ Важно:

**GitHub НЕ показывает значения секретов** по соображениям безопасности. Вы можете только:
- ✅ Видеть **названия** секретов
- ✅ **Редактировать** секреты (иконка карандаша)
- ✅ **Удалять** секреты (иконка корзины)
- ❌ **НЕ можете** посмотреть текущее значение

---

## 🔧 Как проверить значения:

### Вариант 1: Редактировать секрет

1. Нажмите на иконку **редактирования** (карандаш) рядом с секретом
2. GitHub покажет поле для редактирования
3. Если поле **пустое** - секрет не установлен
4. Если поле содержит `***` - значение установлено (но не видно)

**⚠️ Не сохраняйте изменения**, если просто проверяете!

### Вариант 2: Удалить и создать заново

Если хотите убедиться, что значение правильное:
1. **Удалите** секрет
2. **Создайте** новый с правильным значением
3. Это гарантирует, что значение точно правильное

---

## ✅ Что проверить:

### 1. `APPLE_CERTIFICATE_PASSWORD`
- Должен существовать
- При редактировании должно быть: `prirodaspa2018`
- Если пусто или другое значение - обновите

### 2. `APPLE_CERTIFICATE_BASE64`
- Должен существовать
- При редактировании должно быть длинное base64 (начинается с `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`)
- Если пусто или другое значение - обновите из `certificate_base64.txt`

### 3. `APPLE_PROVISIONING_PROFILE_BASE64`
- Должен существовать
- Должен быть длинный base64
- Если пусто - обновите из `profile_base64.txt`

### 4. `KEYCHAIN_PASSWORD`
- Должен существовать
- Может быть любым (например, `temp_password`)

---

## 🔗 Прямая ссылка:

```
https://github.com/som1one/SpaApp/settings/secrets/actions
```

Откройте эту ссылку, чтобы сразу попасть на страницу секретов.

---

## 💡 Совет:

Если хотите **точно** убедиться, что значения правильные:
1. **Удалите** секрет
2. **Создайте** новый с правильным значением
3. Это гарантирует, что значение точно правильное

---

**После проверки и обновления секретов, workflow должен пройти успешно!**

