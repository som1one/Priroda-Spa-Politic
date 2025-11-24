"""Проверка типа колонки day_of_week в БД"""
from sqlalchemy import create_engine, text
from app.core.config import settings

engine = create_engine(settings.DATABASE_URL)

with engine.connect() as conn:
    # Проверяем тип колонки
    result = conn.execute(text("""
        SELECT 
            column_name, 
            data_type,
            udt_name
        FROM information_schema.columns 
        WHERE table_name = 'staff_schedules' 
        AND column_name = 'day_of_week'
    """)).fetchone()
    
    if result:
        print(f"Колонка day_of_week:")
        print(f"  - column_name: {result[0]}")
        print(f"  - data_type: {result[1]}")
        print(f"  - udt_name: {result[2]}")
    else:
        print("Колонка не найдена!")
    
    # Проверяем существующие данные
    print("\nСуществующие расписания:")
    schedules = conn.execute(text("SELECT id, staff_id, day_of_week, start_time, end_time FROM staff_schedules")).fetchall()
    for s in schedules:
        print(f"  ID: {s[0]}, Staff: {s[1]}, Day: {s[2]} (type: {type(s[2])}), {s[3]} - {s[4]}")

