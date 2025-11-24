"""
Скрипт для проверки колонок в таблицах staff и staff_services
"""
import sys
import os
from pathlib import Path

# Добавляем корневую директорию проекта в PYTHONPATH
backend_dir = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(backend_dir))

from sqlalchemy import create_engine, text
from app.core.config import settings

def check_columns():
    """Проверить колонки в таблицах staff и staff_services"""
    # Создаем подключение к БД
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        print("=" * 60)
        print("ПРОВЕРКА КОЛОНОК В ТАБЛИЦЕ staff")
        print("=" * 60)
        
        result = conn.execute(text("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'staff'
            ORDER BY ordinal_position;
        """))
        
        for row in result:
            print(f"  {row[0]:<20} {row[1]:<20} nullable={row[2]:<5} default={row[3] or 'None'}")
        
        print("\n" + "=" * 60)
        print("ПРОВЕРКА КОЛОНОК В ТАБЛИЦЕ staff_services")
        print("=" * 60)
        
        result = conn.execute(text("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns 
            WHERE table_name = 'staff_services'
            ORDER BY ordinal_position;
        """))
        
        for row in result:
            print(f"  {row[0]:<20} {row[1]:<20} nullable={row[2]:<5} default={row[3] or 'None'}")
        
        print("\n" + "=" * 60)
        print("ПРОВЕРКА ЗАВЕРШЕНА")
        print("=" * 60)

if __name__ == "__main__":
    try:
        check_columns()
    except Exception as e:
        print(f"\n✗ ОШИБКА: {e}")
        import traceback
        traceback.print_exc()

