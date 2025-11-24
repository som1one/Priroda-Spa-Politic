"""
Скрипт для тестирования синхронизации записей из YClients
"""
import sys
import os
import asyncio

# Добавляем корневую директорию в путь
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import settings
from app.services.yclients_service import yclients_service
from app.services.booking_sync_service import sync_yclients_bookings

def main():
    print("=" * 60)
    print("🧪 Тест синхронизации записей из YClients")
    print("=" * 60)
    print()
    
    # Проверка конфигурации
    if not settings.YCLIENTS_ENABLED:
        print("❌ YCLIENTS_ENABLED = False")
        print("💡 Установите YCLIENTS_ENABLED=True в .env")
        return
    
    if not settings.YCLIENTS_COMPANY_ID:
        print("❌ YCLIENTS_COMPANY_ID не установлен")
        return
    
    print("✅ Конфигурация проверена")
    print()
    
    # Настройка YClients
    yclients_service.configure(
        company_id=settings.YCLIENTS_COMPANY_ID,
        api_token=settings.YCLIENTS_API_TOKEN,
        user_token=settings.YCLIENTS_USER_TOKEN,
    )
    
    print("📋 Тест 1: Получение записей из YClients...")
    try:
        async def test_get_bookings():
            from datetime import date, timedelta
            bookings = await yclients_service.get_bookings(
                date_from=date.today(),
                date_to=date.today() + timedelta(days=30),
            )
            if bookings:
                print(f"   ✅ Получено {len(bookings)} записей из YClients")
                print(f"   📝 Пример первой записи:")
                if len(bookings) > 0:
                    first = bookings[0]
                    print(f"      - ID: {first.get('id')}")
                    print(f"      - Дата: {first.get('date')} {first.get('time')}")
                    client = first.get('client', {})
                    print(f"      - Клиент: {client.get('name', 'N/A')} ({client.get('email', 'N/A')})")
                return True
            else:
                print("   ⚠️ Записи не найдены (это нормально, если нет записей)")
                return True
        result = asyncio.run(test_get_bookings())
        if not result:
            print("   ❌ Ошибка получения записей")
            return
    except Exception as e:
        print(f"   ❌ Ошибка: {e}")
        return
    
    print()
    print("📋 Тест 2: Запуск синхронизации...")
    try:
        asyncio.run(sync_yclients_bookings())
        print("   ✅ Синхронизация завершена")
        print("   💡 Проверьте логи выше для деталей")
    except Exception as e:
        print(f"   ❌ Ошибка синхронизации: {e}")
        return
    
    print()
    print("=" * 60)
    print("✅ Тестирование завершено!")
    print("=" * 60)
    print()
    print("💡 Следующие шаги:")
    print("   1. Проверьте логи выше на наличие ошибок")
    print("   2. Проверьте БД на наличие синхронизированных записей")
    print("   3. Проверьте работу webhook (если настроен)")
    print()

if __name__ == "__main__":
    main()

