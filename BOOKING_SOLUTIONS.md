# Решения для системы записи: с YClients и без

## 📋 Обзор

Документ описывает два варианта реализации системы записи на услуги:
1. **С интеграцией YClients** - использование внешнего сервиса для управления записями
2. **Без YClients** - собственная реализация системы записи

---

## 🎯 Вариант 1: Запись с интеграцией YClients

### Преимущества
- ✅ Готовое решение для управления записями
- ✅ Встроенная система оплаты
- ✅ Календарь и расписание мастеров
- ✅ SMS и email уведомления
- ✅ Мобильное приложение для администраторов
- ✅ Статистика и аналитика
- ✅ Интеграция с бухгалтерией
- ✅ Меньше разработки на нашей стороне

### Недостатки
- ❌ Зависимость от внешнего сервиса
- ❌ Дополнительные расходы на подписку YClients
- ❌ Ограниченная кастомизация UI
- ❌ Необходимость синхронизации данных
- ❌ Возможные задержки при синхронизации

### Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App                               │
│                                                              │
│  ServiceDetailScreen → YClientsBookingScreen (WebView)      │
│                                                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ GET /api/v1/yclients/widget-url/{service_id}
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API                               │
│                                                              │
│  1. Получение URL виджета YClients                          │
│  2. Предзаполнение данных пользователя                      │
│  3. Синхронизация записей из YClients                       │
│  4. Webhook для получения уведомлений                       │
│                                                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ API Calls / Webhooks
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    YClients Service                         │
│                                                              │
│  • Управление записями                                       │
│  • Календарь и расписание                                   │
│  • Оплата                                                    │
│  • Уведомления                                               │
│  • Статистика                                                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Реализация

#### 1. Получение URL виджета YClients

**Endpoint:** `GET /api/v1/yclients/widget-url/{service_id}`

**Что делает:**
- Получает услугу из БД
- Формирует URL виджета YClients
- Добавляет параметры предзаполнения:
  - `services={yclients_service_id}` - ID услуги
  - `staff={yclients_staff_id}` - ID мастера (опционально)
  - `client_name={name} {surname}` - Имя пользователя
  - `client_email={email}` - Email
  - `client_phone={phone}` - Телефон (формат +7XXXXXXXXXX)

**Пример URL:**
```
https://yclients.com/timetable/235564?services=5147108&client_name=Иван%20Иванов&client_email=ivan@example.com&client_phone=%2B79991234567
```

#### 2. Flutter: YClientsBookingScreen

**Файл:** `spa/lib/screens/booking/yclients_booking_screen.dart`

**Что делает:**
- Загружает URL виджета через API
- Отображает WebView с виджетом YClients
- Отслеживает изменения URL для определения успешного бронирования
- Показывает диалог успеха после бронирования

**Ключевые моменты:**
```dart
// Отслеживание успешного бронирования
void _checkForBookingSuccess(String url) {
  if (url.contains('success') || 
      url.contains('confirmed') || 
      url.contains('record_id=')) {
    _handleBookingSuccess();
  }
}
```

#### 3. Синхронизация записей

**Endpoint:** `POST /api/v1/yclients/sync-bookings`

**Что делает:**
- Получает записи из YClients за период (последние 30 дней)
- Сопоставляет пользователей по email/телефону
- Создает/обновляет записи в локальной БД
- Обновляет статусы записей

**Периодичность:**
- Автоматически: каждые 30 минут (через APScheduler)
- Вручную: через API endpoint
- Webhook: при изменениях в YClients (мгновенно)

#### 4. Webhook от YClients

**Endpoint:** `POST /api/v1/yclients/webhook`

**Что обрабатывает:**
- Создание новой записи
- Изменение статуса записи
- Отмена записи
- Изменение даты/времени

**Настройка в YClients:**
- URL: `https://your-domain.com/api/v1/yclients/webhook`
- События: все изменения записей

### Поток данных

```
1. Пользователь выбирает услугу
   ↓
2. Flutter → GET /api/v1/yclients/widget-url/{service_id}
   ↓
3. Backend формирует URL с предзаполнением
   ↓
4. Flutter открывает WebView с виджетом YClients
   ↓
5. Пользователь в виджете:
   - Выбирает мастера
   - Выбирает дату и время
   - Проверяет/редактирует данные
   - Оплачивает (в виджете)
   ↓
6. YClients создает запись
   ↓
7. Webhook → POST /api/v1/yclients/webhook
   ↓
8. Backend синхронизирует запись в локальную БД
   ↓
9. Flutter отслеживает успех и показывает диалог
   ↓
10. Пользователь видит запись в списке бронирований
```

### Необходимые настройки

1. **YClients аккаунт:**
   - Company ID
   - API Token (Partner Token)
   - User Token (токен сотрудника/админа)

2. **Backend .env:**
   ```env
   YCLIENTS_ENABLED=True
   YCLIENTS_COMPANY_ID=235564
   YCLIENTS_API_TOKEN=your-api-token
   YCLIENTS_USER_TOKEN=your-user-token
   ```

3. **Синхронизация услуг и мастеров:**
   ```bash
   python scripts/sync_yclients_catalog.py
   ```

4. **Настройка webhook в YClients:**
   - URL: `https://your-domain.com/api/v1/yclients/webhook`
   - События: все изменения записей

### Обработка ошибок

- **Услуга не привязана к YClients:**
  - Показывается сообщение об ошибке
  - Предлагается связать услугу в админке

- **YClients недоступен:**
  - Fallback на локальное расписание (если настроено)
  - Показывается сообщение об ошибке

- **Ошибка синхронизации:**
  - Логируется ошибка
  - Повторная попытка через 5 минут
  - Ручная синхронизация через API

---

## 🎯 Вариант 2: Запись без YClients (собственная реализация)

### Преимущества
- ✅ Полный контроль над процессом
- ✅ Кастомизация под нужды бизнеса
- ✅ Нет зависимости от внешних сервисов
- ✅ Нет дополнительных расходов на подписку
- ✅ Прямая интеграция с нашей системой
- ✅ Собственный дизайн и UX

### Недостатки
- ❌ Больше разработки
- ❌ Необходимость реализации:
  - Календаря и расписания
  - Управления мастерами
  - Системы оплаты
  - Уведомлений (SMS/Email)
  - Статистики
- ❌ Больше поддержки и обслуживания

### Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App                               │
│                                                              │
│  ServiceDetailScreen → BookingScreen → BookingDetailsScreen │
│  → PaymentScreen → ConfirmationScreen                        │
│                                                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ API Calls
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API                               │
│                                                              │
│  1. GET /api/v1/booking/time-slots/{service_id}            │
│     - Получение доступных слотов времени                    │
│                                                              │
│  2. POST /api/v1/bookings                                   │
│     - Создание бронирования                                 │
│     - Валидация доступности                                │
│     - Резервирование времени                                │
│                                                              │
│  3. GET /api/v1/bookings                                    │
│     - Список бронирований пользователя                     │
│                                                              │
│  4. PATCH /api/v1/bookings/{id}                            │
│     - Отмена бронирования                                  │
│                                                              │
│  5. POST /api/v1/payments                                   │
│     - Обработка оплаты                                     │
│                                                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    Database (PostgreSQL)                    │
│                                                              │
│  • services - услуги                                        │
│  • staff - мастера                                          │
│  • staff_schedules - расписание мастеров                    │
│  • bookings - бронирования                                 │
│  • payments - платежи                                       │
│  • time_slots - доступные слоты времени                    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Реализация

#### 1. Получение доступных слотов времени

**Endpoint:** `GET /api/v1/booking/time-slots/{service_id}?staff_id={staff_id}&date={date}`

**Что делает:**
- Получает расписание мастера на указанную дату
- Проверяет существующие бронирования
- Генерирует список доступных слотов
- Учитывает перерывы и нерабочие дни

**Пример ответа:**
```json
{
  "date": "2025-01-15",
  "service_id": 1,
  "staff_id": 1,
  "slots": [
    {
      "time": "09:00",
      "available": true,
      "duration": 60
    },
    {
      "time": "10:00",
      "available": true,
      "duration": 60
    },
    {
      "time": "11:00",
      "available": false,
      "reason": "Уже забронировано"
    }
  ]
}
```

**Логика генерации слотов:**
```python
def generate_time_slots(staff_schedule, service_duration, existing_bookings, target_date):
    slots = []
    start_time = staff_schedule.start_time
    end_time = staff_schedule.end_time
    
    current_time = start_time
    while current_time + service_duration <= end_time:
        # Проверка перерыва
        if is_break_time(current_time, staff_schedule):
            current_time = staff_schedule.break_end
            continue
        
        # Проверка существующих бронирований
        if is_slot_available(current_time, service_duration, existing_bookings):
            slots.append({
                "time": current_time.strftime("%H:%M"),
                "available": True,
                "duration": service_duration
            })
        
        current_time += timedelta(minutes=30)  # Шаг 30 минут
    
    return slots
```

#### 2. Создание бронирования

**Endpoint:** `POST /api/v1/bookings`

**Body:**
```json
{
  "service_id": 1,
  "staff_id": 1,
  "appointment_datetime": "2025-01-15T10:00:00Z",
  "phone": "+79991234567",
  "notes": "Комментарий от клиента",
  "additional_services": [2, 3]
}
```

**Что делает:**
- Валидирует доступность слота
- Проверяет, что время не в прошлом
- Проверяет, что мастер доступен
- Резервирует время (создает бронирование)
- Отправляет email уведомление
- Возвращает созданное бронирование

**Валидация:**
```python
async def create_booking(booking_data, user_id, db):
    # Проверка доступности слота
    if not await is_slot_available(
        booking_data.staff_id,
        booking_data.appointment_datetime,
        booking_data.service.duration,
        db
    ):
        raise HTTPException(400, "Время уже занято")
    
    # Проверка, что время не в прошлом
    if booking_data.appointment_datetime < datetime.now():
        raise HTTPException(400, "Нельзя забронировать время в прошлом")
    
    # Создание бронирования
    booking = Booking(
        user_id=user_id,
        service_id=booking_data.service_id,
        staff_id=booking_data.staff_id,
        appointment_datetime=booking_data.appointment_datetime,
        status="pending",
        phone=booking_data.phone,
        notes=booking_data.notes
    )
    
    db.add(booking)
    db.commit()
    
    # Отправка уведомления
    await send_booking_confirmation_email(booking)
    
    return booking
```

#### 3. Flutter: BookingScreen

**Файл:** `spa/lib/screens/booking/booking_screen.dart`

**Что делает:**
- Показывает календарь для выбора даты
- Загружает доступные слоты времени через API
- Отображает список доступных времен
- Переход на следующий экран с выбранными данными

**Ключевые моменты:**
```dart
// Загрузка слотов
Future<void> _loadTimeSlots(DateTime date) async {
  final slots = await apiService.getTimeSlots(
    serviceId: widget.serviceId,
    staffId: selectedStaffId,
    date: date,
  );
  setState(() {
    availableSlots = slots;
  });
}

// Выбор времени
void _selectTime(TimeSlot slot) {
  setState(() {
    selectedTime = slot.time;
  });
}
```

#### 4. Flutter: BookingDetailsScreen

**Файл:** `spa/lib/screens/booking/booking_details_screen.dart`

**Что делает:**
- Показывает выбранную дату и время
- Поля для дополнительных услуг
- Поле для комментария
- Поле для телефона (автозаполнение)
- Итоговая стоимость
- Кнопка "Продолжить к оплате"

#### 5. Flutter: PaymentScreen

**Файл:** `spa/lib/screens/booking/payment_screen.dart`

**Что делает:**
- Форма для данных карты
- Поддержка Apple Pay / Google Pay
- Использование баллов лояльности
- Обработка оплаты
- Создание бронирования после оплаты

**Интеграция оплаты:**
```dart
// После успешной оплаты
final booking = await apiService.createBooking(
  serviceId: serviceId,
  staffId: staffId,
  appointmentDateTime: appointmentDateTime,
  phone: phone,
  notes: notes,
);

// Переход на экран подтверждения
Navigator.pushNamed(
  context,
  RouteNames.bookingConfirmation,
  arguments: booking,
);
```

#### 6. Управление расписанием мастеров

**Таблица:** `staff_schedules`

**Структура:**
```sql
CREATE TABLE staff_schedules (
    id SERIAL PRIMARY KEY,
    staff_id INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,  -- 0=Monday, 6=Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    break_start TIME,
    break_end TIME,
    is_active BOOLEAN DEFAULT TRUE
);
```

**API для управления:**
- `GET /api/v1/admin/staff/{id}/schedule` - Получить расписание
- `POST /api/v1/admin/staff/{id}/schedule` - Создать расписание
- `PATCH /api/v1/admin/staff/{id}/schedule/{id}` - Обновить расписание
- `DELETE /api/v1/admin/staff/{id}/schedule/{id}` - Удалить расписание

#### 7. Проверка доступности

**Функция:** `is_slot_available()`

**Логика:**
```python
async def is_slot_available(
    staff_id: int,
    appointment_datetime: datetime,
    service_duration: int,
    db: Session
) -> bool:
    # 1. Получить расписание мастера на день недели
    day_of_week = appointment_datetime.weekday()
    schedule = db.query(StaffSchedule).filter(
        StaffSchedule.staff_id == staff_id,
        StaffSchedule.day_of_week == day_of_week,
        StaffSchedule.is_active == True
    ).first()
    
    if not schedule:
        return False
    
    # 2. Проверить, что время в рабочем диапазоне
    appointment_time = appointment_datetime.time()
    if appointment_time < schedule.start_time:
        return False
    
    end_time = (datetime.combine(date.today(), appointment_time) + 
                timedelta(minutes=service_duration)).time()
    if end_time > schedule.end_time:
        return False
    
    # 3. Проверить перерыв
    if schedule.break_start and schedule.break_end:
        if (appointment_time < schedule.break_end and 
            end_time > schedule.break_start):
            return False
    
    # 4. Проверить существующие бронирования
    existing_bookings = db.query(Booking).filter(
        Booking.staff_id == staff_id,
        Booking.appointment_datetime >= appointment_datetime,
        Booking.appointment_datetime < appointment_datetime + timedelta(minutes=service_duration),
        Booking.status.in_(["pending", "confirmed"])
    ).count()
    
    return existing_bookings == 0
```

### Поток данных

```
1. Пользователь выбирает услугу
   ↓
2. Flutter → GET /api/v1/booking/time-slots/{service_id}
   ↓
3. Backend генерирует доступные слоты из расписания
   ↓
4. Flutter показывает календарь и список времен
   ↓
5. Пользователь выбирает дату и время
   ↓
6. Flutter → BookingDetailsScreen
   ↓
7. Пользователь заполняет детали
   ↓
8. Flutter → PaymentScreen
   ↓
9. Пользователь оплачивает
   ↓
10. Flutter → POST /api/v1/bookings
   ↓
11. Backend:
    - Валидирует доступность
    - Создает бронирование
    - Отправляет email
   ↓
12. Flutter показывает подтверждение
   ↓
13. Пользователь видит запись в списке
```

### Необходимые компоненты

1. **База данных:**
   - Таблица `staff_schedules` (уже есть)
   - Таблица `bookings` (уже есть)
   - Таблица `payments` (нужно создать)
   - Таблица `time_slots` (опционально, для кеширования)

2. **Backend API:**
   - `GET /api/v1/booking/time-slots/{service_id}` (уже есть)
   - `POST /api/v1/bookings` (уже есть, нужно доработать)
   - `GET /api/v1/bookings` (уже есть)
   - `PATCH /api/v1/bookings/{id}` (отмена)
   - `POST /api/v1/payments` (нужно создать)

3. **Flutter экраны:**
   - `BookingScreen` (уже есть, нужно доработать)
   - `BookingDetailsScreen` (уже есть, нужно доработать)
   - `PaymentScreen` (нужно создать или доработать)
   - `ConfirmationScreen` (нужно создать)

4. **Интеграции:**
   - Платежная система (Stripe, ЮKassa, и т.д.)
   - Email сервис (уже есть)
   - SMS сервис (опционально)

### Обработка ошибок

- **Слот уже занят:**
  - Показывается сообщение
  - Предлагается выбрать другое время
  - Автоматическое обновление списка слотов

- **Мастер недоступен:**
  - Показывается сообщение
  - Предлагается выбрать другого мастера

- **Ошибка оплаты:**
  - Показывается сообщение об ошибке
  - Бронирование не создается
  - Предлагается повторить оплату

---

## 🔄 Гибридный вариант (рекомендуется)

### Концепция

Использовать YClients для услуг, которые привязаны к YClients, и собственную систему для остальных.

### Логика выбора

```python
async def get_booking_method(service_id: int, db: Session):
    service = db.query(Service).filter(Service.id == service_id).first()
    
    if service.yclients_service_id:
        # Использовать YClients
        return "yclients"
    else:
        # Использовать собственную систему
        return "internal"
```

### Преимущества

- ✅ Гибкость: можно использовать оба подхода
- ✅ Постепенный переход: можно мигрировать услуги по одной
- ✅ Резервный вариант: если YClients недоступен, используется локальная система
- ✅ Оптимизация: для простых услуг - своя система, для сложных - YClients

### Реализация

**В BookingScreen:**
```dart
Future<void> _handleBooking() async {
  final service = await apiService.getService(serviceId);
  
  if (service.yclientsServiceId != null) {
    // Переход на YClients виджет
    Navigator.pushNamed(
      context,
      RouteNames.yclientsBooking,
      arguments: {'serviceId': serviceId},
    );
  } else {
    // Переход на собственную систему записи
    Navigator.pushNamed(
      context,
      RouteNames.booking,
      arguments: {'serviceId': serviceId},
    );
  }
}
```

**В Backend:**
```python
@router.get("/time-slots/{service_id}")
async def get_time_slots(service_id: int, ...):
    service = db.query(Service).filter(Service.id == service_id).first()
    
    # Если YClients включен и услуга привязана
    if settings.YCLIENTS_ENABLED and service.yclients_service_id:
        # Получаем слоты из YClients
        return await get_yclients_time_slots(service, staff_id, date)
    else:
        # Генерируем слоты из локального расписания
        return await generate_local_time_slots(service, staff_id, date)
```

---

## 📊 Сравнительная таблица

| Критерий | С YClients | Без YClients | Гибридный |
|----------|-----------|-------------|-----------|
| **Время разработки** | 1-2 недели | 2-3 месяца | 2-3 недели |
| **Стоимость** | Подписка YClients | Только разработка | Подписка + разработка |
| **Кастомизация** | Ограничена | Полная | Частичная |
| **Зависимости** | YClients API | Нет | YClients API (частично) |
| **Поддержка** | YClients | Наша | Смешанная |
| **Масштабируемость** | Высокая | Средняя | Высокая |
| **Интеграция** | Готовая | Нужна разработка | Частично готовая |
| **Оплата** | Встроена | Нужна интеграция | Встроена (YClients) / Нужна (своя) |
| **Уведомления** | Встроены | Нужна разработка | Встроены (YClients) / Нужны (своя) |

---

## 🎯 Рекомендации

### Для быстрого запуска:
**Использовать YClients** - минимальная разработка, готовое решение

### Для полного контроля:
**Собственная система** - больше времени на разработку, но полный контроль

### Для оптимального баланса:
**Гибридный вариант** - использовать YClients для основных услуг, свою систему для специальных случаев

---

## 📝 Следующие шаги

1. **Определить приоритеты:**
   - Скорость запуска vs контроль
   - Бюджет на подписку vs разработку
   - Необходимость кастомизации

2. **Выбрать вариант:**
   - С YClients
   - Без YClients
   - Гибридный

3. **Составить план разработки:**
   - Список задач
   - Оценка времени
   - Необходимые ресурсы

4. **Начать реализацию:**
   - Настроить инфраструктуру
   - Реализовать базовые функции
   - Тестирование
   - Запуск

---

## 🔗 Связанные документы

- `BOOKING_FLOW.md` - Описание текущего флоу бронирования
- `BOOKING_FLOW_DETAILED.md` - Детальное описание с YClients
- `YCLIENTS_INTEGRATION.md` - Документация по интеграции YClients
- `YCLIENTS_SETUP_COMPLETE.md` - Инструкция по настройке YClients

