# Альтернативы виджету YClients для бронирования

## Проблема
YClients требует создание филиала для регистрации, что усложняет интеграцию. Нужны альтернативные решения для бронирования услуг из YClients.

---

## Вариант 1: YPlaces веб-виджет (Рекомендуется)

### Описание
YPlaces предоставляет готовый веб-виджет для онлайн-записи, который можно встроить в приложение через WebView.

### Преимущества
- ✅ Готовый виджет, не требует разработки UI
- ✅ Интеграция через WebView (как сейчас с YClients)
- ✅ Не требует создания филиала
- ✅ Простая настройка через API ключ

### Недостатки
- ⚠️ Нужна регистрация в YPlaces
- ⚠️ Возможны дополнительные расходы
- ⚠️ Зависимость от стороннего сервиса

### Реализация

#### Backend: Новый endpoint для YPlaces виджета
```python
# backend/app/api/v1/yplaces.py
@router.get("/widget-url/{service_id}")
async def get_yplaces_widget_url(
    service_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Генерирует URL для YPlaces виджета с предзаполненными данными
    """
    service = db.query(Service).filter(Service.id == service_id).first()
    if not service:
        raise HTTPException(status_code=404, detail="Услуга не найдена")
    
    # YPlaces виджет URL
    widget_url = f"https://yplaces.com/widget/{YPLACES_COMPANY_ID}"
    
    params = {
        'service_id': service.yclients_service_id or service.id,
        'client_name': f"{current_user.name} {current_user.surname}".strip(),
        'client_phone': current_user.phone or '',
        'client_email': current_user.email,
    }
    
    widget_url += "?" + "&".join([f"{k}={v}" for k, v in params.items() if v])
    
    return {"widget_url": widget_url}
```

#### Flutter: Адаптация существующего экрана
- Использовать существующий `YClientsBookingScreen`
- Изменить endpoint с `/yclients/widget-url/` на `/yplaces/widget-url/`
- Остальная логика остается той же

### Настройка
1. Зарегистрироваться в YPlaces
2. Получить `YPLACES_COMPANY_ID`
3. Добавить в `.env`:
   ```
   YPLACES_ENABLED=True
   YPLACES_COMPANY_ID=your_company_id
   ```

---

## Вариант 2: Собственный UI с YClients API (Костыль)

### Описание
Создать собственный интерфейс бронирования в Flutter, который использует YClients API для создания записей напрямую, минуя виджет.

### Преимущества
- ✅ Полный контроль над UI/UX
- ✅ Не зависит от виджетов
- ✅ Использует существующую YClients интеграцию
- ✅ Не требует дополнительных сервисов

### Недостатки
- ⚠️ Нужна разработка собственного UI
- ⚠️ Нужно поддерживать логику выбора времени
- ⚠️ Больше кода для поддержки

### Реализация

#### Backend: Использовать существующие endpoints
- `/booking/time-slots/` - уже есть
- `/booking/create` - уже есть, создает запись через YClients API

#### Flutter: Новый экран бронирования
```dart
// spa/lib/screens/booking/custom_booking_screen.dart
class CustomBookingScreen extends StatefulWidget {
  final int serviceId;
  final int? staffId;
  
  const CustomBookingScreen({
    required this.serviceId,
    this.staffId,
  });
  
  // Использует существующий TimeSelectionScreen
  // + кастомный UI для выбора мастера и подтверждения
}
```

**Что нужно добавить:**
1. Экран выбора мастера (если не выбран)
2. Календарь с доступными датами (уже есть в `TimeSelectionScreen`)
3. Список доступных слотов времени (уже есть)
4. Форма подтверждения с комментарием
5. Создание записи через `/booking/create`

### Структура
```
TimeSelectionScreen (уже есть)
  ↓
CustomBookingScreen (новый)
  ├── Выбор мастера (если нужно)
  ├── Календарь (из TimeSelectionScreen)
  ├── Список слотов (из TimeSelectionScreen)
  ├── Форма комментария
  └── Кнопка "Забронировать" → POST /booking/create
```

---

## Вариант 3: Гибридный подход (YClients API + Fallback UI)

### Описание
Использовать собственный UI для бронирования, но с возможностью переключения на YClients виджет, если он доступен.

### Преимущества
- ✅ Гибкость: работает и с виджетом, и без него
- ✅ Лучший UX: собственный UI адаптирован под приложение
- ✅ Fallback: если виджет недоступен, используется собственный UI

### Реализация

#### Backend: Проверка доступности виджета
```python
@router.get("/booking/method/{service_id}")
async def get_booking_method(service_id: int):
    """
    Определяет, какой метод бронирования использовать
    """
    service = db.query(Service).filter(Service.id == service_id).first()
    
    # Если есть YClients ID и виджет доступен
    if service.yclients_service_id and YCLIENTS_WIDGET_ENABLED:
        return {"method": "widget", "url": f"/yclients/widget-url/{service_id}"}
    
    # Иначе используем собственный UI
    return {"method": "custom", "endpoint": "/booking/create"}
```

#### Flutter: Умный роутинг
```dart
// При нажатии "Забронировать" на услуге
Future<void> _navigateToBooking(int serviceId) async {
  final method = await apiService.get('/booking/method/$serviceId');
  
  if (method['method'] == 'widget') {
    // Используем виджет
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YClientsBookingScreen(serviceId: serviceId),
      ),
    );
  } else {
    // Используем собственный UI
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomBookingScreen(serviceId: serviceId),
      ),
    );
  }
}
```

---

## Вариант 4: Внешняя ссылка на YClients (Простой костыль)

### Описание
Просто открывать внешнюю ссылку на страницу бронирования YClients в браузере или WebView.

### Преимущества
- ✅ Минимальная реализация
- ✅ Не требует разработки UI
- ✅ Работает сразу

### Недостатки
- ⚠️ Плохой UX (выход из приложения)
- ⚠️ Нет контроля над процессом
- ⚠️ Нет автоматической синхронизации

### Реализация

#### Backend: Простой endpoint
```python
@router.get("/yclients/booking-link/{service_id}")
async def get_yclients_booking_link(service_id: int):
    service = db.query(Service).filter(Service.id == service_id).first()
    if not service or not service.yclients_service_id:
        raise HTTPException(status_code=404, detail="Услуга не найдена")
    
    # Прямая ссылка на страницу бронирования YClients
    link = f"https://yclients.com/timetable/{YCLIENTS_COMPANY_ID}?service_id={service.yclients_service_id}"
    return {"booking_link": link}
```

#### Flutter: Открытие в браузере
```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> _openBookingLink(int serviceId) async {
  final response = await apiService.get('/yclients/booking-link/$serviceId');
  final link = response['booking_link'];
  
  if (await canLaunchUrl(Uri.parse(link))) {
    await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }
}
```

---

## Сравнение вариантов

| Критерий | Вариант 1 (YPlaces) | Вариант 2 (Собственный UI) | Вариант 3 (Гибрид) | Вариант 4 (Внешняя ссылка) |
|----------|---------------------|---------------------------|---------------------|---------------------------|
| Сложность реализации | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐ |
| Качество UX | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Зависимость от сервисов | Высокая | Низкая | Средняя | Низкая |
| Стоимость | Может быть платно | Бесплатно | Бесплатно | Бесплатно |
| Время разработки | 1-2 дня | 3-5 дней | 4-6 дней | 1 час |

---

## Рекомендация

**Для быстрого решения:** Вариант 2 (Собственный UI с YClients API)
- Использует существующую инфраструктуру
- Не требует дополнительных сервисов
- Хороший UX
- Можно реализовать на базе существующего `TimeSelectionScreen`

**Для долгосрочного решения:** Вариант 3 (Гибридный подход)
- Максимальная гибкость
- Лучший UX
- Работает в любых условиях

---

## План реализации (Вариант 2)

### Этап 1: Backend (уже готов)
- ✅ `/booking/time-slots/` - получение доступных слотов
- ✅ `/booking/create` - создание записи через YClients API
- ✅ `/booking/available-days/` - получение доступных дат

### Этап 2: Flutter - Улучшение TimeSelectionScreen
1. Добавить выбор мастера (если не выбран)
2. Добавить форму комментария
3. Добавить кнопку "Забронировать"
4. Интегрировать с `/booking/create`

### Этап 3: Интеграция в ServiceDetailScreen
- Заменить переход на `YClientsBookingScreen` на `CustomBookingScreen`
- Или использовать существующий `TimeSelectionScreen` с доработками

---

## Файлы для изменения

### Backend
- `backend/app/api/v1/booking.py` - уже готов
- `backend/app/services/yclients_service.py` - уже готов

### Flutter
- `spa/lib/screens/booking/time_selection_screen.dart` - доработать
- `spa/lib/screens/booking/custom_booking_screen.dart` - создать (опционально)
- `spa/lib/screens/menu/service_detail_screen.dart` - изменить навигацию

---

## Вопросы для уточнения

1. Есть ли у вас аккаунт в YPlaces?
2. Готовы ли платить за YPlaces, если это платный сервис?
3. Предпочитаете быструю реализацию (Вариант 2) или долгосрочное решение (Вариант 3)?
4. Нужна ли возможность выбора мастера в процессе бронирования?

