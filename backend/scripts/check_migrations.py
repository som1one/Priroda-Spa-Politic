"""
Скрипт для проверки, что все миграции применены и таблицы созданы
"""
import sys
from pathlib import Path

# Добавляем корневую директорию проекта в PYTHONPATH
backend_dir = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(backend_dir))

from sqlalchemy import inspect
from app.core.database import engine


def check_tables():
    """Проверить, что все необходимые таблицы и поля существуют"""
    inspector = inspect(engine)
    
    print("=" * 60)
    print("ПРОВЕРКА ТАБЛИЦ И ПОЛЕЙ ДЛЯ ПРОГРАММЫ ЛОЯЛЬНОСТИ")
    print("=" * 60)
    
    # Проверка таблиц лояльности
    tables = inspector.get_table_names()
    print("\n1. Проверка таблиц лояльности:")
    required_tables = ['loyalty_levels', 'loyalty_bonuses']
    for table in required_tables:
        if table in tables:
            print(f"   ✓ Таблица '{table}' существует")
        else:
            print(f"   ✗ Таблица '{table}' НЕ существует!")
    
    # Проверка полей в users
    print("\n2. Проверка полей в таблице 'users':")
    if 'users' in tables:
        user_columns = {col['name']: col for col in inspector.get_columns('users')}
        required_user_fields = ['loyalty_level', 'auto_apply_loyalty_points']
        for field in required_user_fields:
            if field in user_columns:
                print(f"   ✓ Поле '{field}' существует")
            else:
                print(f"   ✗ Поле '{field}' НЕ существует!")
    else:
        print("   ✗ Таблица 'users' не существует!")
    
    # Проверка полей в bookings
    print("\n3. Проверка полей в таблице 'bookings':")
    if 'bookings' in tables:
        booking_columns = {col['name']: col for col in inspector.get_columns('bookings')}
        required_booking_fields = ['loyalty_points_awarded', 'loyalty_points_amount']
        for field in required_booking_fields:
            if field in booking_columns:
                print(f"   ✓ Поле '{field}' существует")
            else:
                print(f"   ✗ Поле '{field}' НЕ существует!")
    else:
        print("   ✗ Таблица 'bookings' не существует!")
    
    print("\n" + "=" * 60)
    print("Проверка завершена!")
    print("=" * 60)


if __name__ == "__main__":
    check_tables()

