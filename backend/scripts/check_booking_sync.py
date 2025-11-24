"""
Скрипт для проверки синхронизации записей из YClients
"""
import sys
import os
from datetime import date, timedelta

# Добавляем путь к проекту
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import create_engine, text
from app.core.config import settings
from app.core.database import SessionLocal
from app.models.booking import Booking
from app.models.user import User


def main():
    """Проверка синхронизации записей"""
    print("=" * 60)
    print("ПРОВЕРКА СИНХРОНИЗАЦИИ ЗАПИСЕЙ ИЗ YCLIENTS")
    print("=" * 60)
    
    db = SessionLocal()
    try:
        # 1. Проверяем настройки YClients
        print("\n1. Настройки YClients:")
        print(f"   YCLIENTS_ENABLED: {settings.YCLIENTS_ENABLED}")
        print(f"   YCLIENTS_COMPANY_ID: {settings.YCLIENTS_COMPANY_ID}")
        print(f"   YCLIENTS_API_TOKEN: {'Установлен' if settings.YCLIENTS_API_TOKEN else 'НЕ УСТАНОВЛЕН'}")
        print(f"   YCLIENTS_USER_TOKEN: {'Установлен' if settings.YCLIENTS_USER_TOKEN else 'НЕ УСТАНОВЛЕН'}")
        
        if not settings.YCLIENTS_ENABLED:
            print("\n⚠️  YClients интеграция отключена!")
            return
        
        # 2. Проверяем записи в БД
        print("\n2. Записи в локальной БД:")
        total_bookings = db.query(Booking).count()
        print(f"   Всего записей: {total_bookings}")
        
        # Записи из YClients
        yclients_bookings = db.query(Booking).filter(
            Booking.notes.contains("YClients")
        ).count()
        print(f"   Записей из YClients: {yclients_bookings}")
        
        # Записи с уникальным кодом
        bookings_with_code = db.query(Booking).filter(
            Booking.notes.contains("Код клиента:")
        ).count()
        print(f"   Записей с уникальным кодом: {bookings_with_code}")
        
        # Предстоящие записи
        from datetime import datetime
        upcoming = db.query(Booking).filter(
            Booking.appointment_datetime >= datetime.now(),
            Booking.status.in_(["PENDING", "CONFIRMED"])
        ).count()
        print(f"   Предстоящих записей: {upcoming}")
        
        # 3. Проверяем пользователей с кодами
        print("\n3. Пользователи с уникальными кодами:")
        users_with_code = db.query(User).filter(User.unique_code.isnot(None)).count()
        total_users = db.query(User).count()
        print(f"   Пользователей с кодом: {users_with_code} из {total_users}")
        
        if users_with_code < total_users:
            print(f"   ⚠️  {total_users - users_with_code} пользователей без кода!")
            print("   Запустите: python scripts/generate_unique_codes.py")
        
        # 4. Последние синхронизированные записи
        print("\n4. Последние 5 записей из YClients:")
        recent_bookings = db.query(Booking).filter(
            Booking.notes.contains("YClients")
        ).order_by(Booking.created_at.desc()).limit(5).all()
        
        if recent_bookings:
            for booking in recent_bookings:
                user = db.query(User).filter(User.id == booking.user_id).first()
                print(f"   - {booking.service_name}")
                print(f"     Дата: {booking.appointment_datetime.strftime('%d.%m.%Y %H:%M')}")
                print(f"     Статус: {booking.status.value}")
                print(f"     Пользователь: {user.name if user else 'Не найден'} ({user.email if user else 'N/A'})")
                print(f"     Код: {user.unique_code if user and user.unique_code else 'Нет'}")
                print()
        else:
            print("   Нет записей из YClients")
        
        # 5. Записи без привязки к пользователю
        print("\n5. Записи без привязки к пользователю:")
        bookings_without_user = db.query(Booking).filter(
            Booking.notes.contains("YClients"),
            ~Booking.notes.contains("Код клиента:")
        ).count()
        print(f"   Записей без кода в комментарии: {bookings_without_user}")
        
        if bookings_without_user > 0:
            print("   ⚠️  Эти записи могут не синхронизироваться правильно!")
        
        # 6. Рекомендации
        print("\n6. Рекомендации:")
        if not settings.YCLIENTS_API_TOKEN or not settings.YCLIENTS_USER_TOKEN:
            print("   ❌ Настройте YCLIENTS_API_TOKEN и YCLIENTS_USER_TOKEN в .env")
        else:
            print("   ✅ Токены YClients настроены")
        
        if users_with_code < total_users:
            print("   ⚠️  Сгенерируйте коды для всех пользователей")
        
        if bookings_without_user > 0:
            print("   ⚠️  Проверьте, что в формах YClients добавляется код клиента")
        
        print("\n   Для ручной синхронизации:")
        print("   curl -X POST 'http://localhost:8000/api/v1/yclients/sync-bookings' \\")
        print("     -H 'Authorization: Bearer YOUR_TOKEN'")
        
        print("\n   Для настройки webhook в YClients:")
        print("   URL: https://ваш-домен.com/api/v1/yclients/webhook")
        print("   События: создание, изменение, отмена записи")
        
    finally:
        db.close()
    
    print("\n" + "=" * 60)


if __name__ == "__main__":
    main()

