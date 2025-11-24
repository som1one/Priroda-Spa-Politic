"""
Диагностика проблем с приглашениями админов
"""
import sys
import os

# Устанавливаем рабочую директорию на backend/ перед импортом settings
# чтобы pydantic_settings мог найти .env файл
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(backend_dir)
sys.path.insert(0, backend_dir)

# Явно загружаем .env файл перед импортом settings
env_path = os.path.join(backend_dir, ".env")
if os.path.exists(env_path):
    # Читаем .env файл напрямую и устанавливаем переменные
    try:
        with open(env_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                # Пропускаем комментарии и пустые строки
                if not line or line.startswith('#'):
                    continue
                # Парсим KEY=VALUE
                if '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip()
                    # Убираем кавычки если есть
                    if value.startswith('"') and value.endswith('"'):
                        value = value[1:-1]
                    elif value.startswith("'") and value.endswith("'"):
                        value = value[1:-1]
                    if key and value:
                        os.environ[key] = value
    except Exception as e:
        print(f"[WARNING] Ошибка чтения .env: {e}")
    
    # Также пробуем через python-dotenv для совместимости
    try:
        from dotenv import load_dotenv
        load_dotenv(env_path, override=True)
    except ImportError:
        pass

from sqlalchemy import inspect
from sqlalchemy.orm import Session
from app.core.database import engine, SessionLocal
from app.models.admin import Admin, AdminInvite, AdminRole
from app.core.config import settings

def check_database_tables():
    """Проверка существования таблиц"""
    print("=" * 60)
    print("Проверка таблиц в БД")
    print("=" * 60)
    
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    
    required_tables = ['admins', 'admin_invites']
    for table in required_tables:
        if table in tables:
            print(f"OK Таблица {table} существует")
            
            # Проверяем колонки
            columns = [col['name'] for col in inspector.get_columns(table)]
            print(f"   Колонки: {', '.join(columns)}")
        else:
            print(f"ERROR Таблица {table} НЕ существует!")

def check_super_admin():
    """Проверка наличия супер-админа"""
    print("\n" + "=" * 60)
    print("Проверка супер-админа")
    print("=" * 60)
    
    db: Session = SessionLocal()
    try:
        super_admin = db.query(Admin).filter(Admin.role == AdminRole.SUPER_ADMIN.value).first()
        if super_admin:
            print(f"OK Супер-админ найден: {super_admin.email}")
            print(f"   ID: {super_admin.id}")
            print(f"   Active: {super_admin.is_active}")
        else:
            print("ERROR Супер-админ НЕ найден!")
            print(f"   SUPER_ADMIN_EMAIL в .env: {settings.SUPER_ADMIN_EMAIL}")
            print("   Создайте супер-админа через скрипт create_super_admin.py")
    finally:
        db.close()

def check_invites():
    """Проверка существующих приглашений"""
    print("\n" + "=" * 60)
    print("Проверка существующих приглашений")
    print("=" * 60)
    
    db: Session = SessionLocal()
    try:
        invites = db.query(AdminInvite).all()
        print(f"Найдено приглашений: {len(invites)}")
        for invite in invites:
            print(f"\n  Email: {invite.email}")
            try:
                print(f"  Role: {invite.role}")
            except AttributeError:
                print(f"  Role: колонка отсутствует в БД")
            print(f"  Accepted: {invite.accepted}")
            print(f"  Expires: {invite.expires_at}")
            print(f"  Token: {invite.token[:20]}...")
    finally:
        db.close()

def check_config():
    """Проверка конфигурации"""
    print("\n" + "=" * 60)
    print("Проверка конфигурации")
    print("=" * 60)
    
    # Проверяем, откуда загружаются настройки
    env_file_path = os.path.join(backend_dir, ".env")
    env_exists = os.path.exists(env_file_path)
    print(f"\n.env файл: {env_file_path}")
    print(f"Существует: {'Да' if env_exists else 'Нет'}")
    
    if env_exists:
        print(f"Размер: {os.path.getsize(env_file_path)} байт")
    
    print(f"\nADMIN_PANEL_BASE_URL: {settings.ADMIN_PANEL_BASE_URL}")
    print(f"ADMIN_INVITE_EXPIRATION_MINUTES: {settings.ADMIN_INVITE_EXPIRATION_MINUTES}")
    print(f"EMAIL_HOST: {settings.EMAIL_HOST}")
    print(f"EMAIL_PORT: {settings.EMAIL_PORT}")
    print(f"EMAIL_USER: {'Установлен' if settings.EMAIL_USER else 'НЕ установлен'}")
    print(f"EMAIL_PASSWORD: {'Установлен' if settings.EMAIL_PASSWORD else 'НЕ установлен'}")
    print(f"EMAIL_FROM: {settings.EMAIL_FROM or 'НЕ установлен'}")
    
    # Показываем реальные значения из переменных окружения
    print("\n--- Переменные окружения (если установлены) ---")
    import os as os_env
    env_vars = [
        'ADMIN_PANEL_BASE_URL',
        'EMAIL_HOST',
        'EMAIL_PORT',
        'EMAIL_USER',
        'EMAIL_FROM',
        'SUPER_ADMIN_EMAIL',
    ]
    for var in env_vars:
        value = os_env.getenv(var)
        if value:
            # Скрываем пароли и токены
            if 'PASSWORD' in var or 'TOKEN' in var or 'SECRET' in var:
                print(f"{var}: {'*' * len(value)}")
            else:
                print(f"{var}: {value}")
        else:
            print(f"{var}: не установлена")
    
    # Показываем, что реально загружено в settings
    print("\n--- Значения из settings (после загрузки) ---")
    print(f"settings.ADMIN_PANEL_BASE_URL: {settings.ADMIN_PANEL_BASE_URL}")
    print(f"settings.EMAIL_HOST: {settings.EMAIL_HOST}")
    print(f"settings.EMAIL_PORT: {settings.EMAIL_PORT}")
    print(f"settings.EMAIL_USER: {'установлен' if settings.EMAIL_USER else 'НЕ установлен'}")
    print(f"settings.EMAIL_FROM: {settings.EMAIL_FROM or 'НЕ установлен'}")
    print(f"settings.SUPER_ADMIN_EMAIL: {settings.SUPER_ADMIN_EMAIL or 'НЕ установлен'}")

def main():
    print("\n" + "=" * 60)
    print("ДИАГНОСТИКА ПРИГЛАШЕНИЙ АДМИНОВ")
    print("=" * 60 + "\n")
    print(f"Рабочая директория: {os.getcwd()}")
    print(f"Путь к .env: {os.path.join(backend_dir, '.env')}")
    print()
    
    check_database_tables()
    check_super_admin()
    check_invites()
    check_config()
    
    print("\n" + "=" * 60)
    print("Диагностика завершена")
    print("=" * 60 + "\n")

if __name__ == "__main__":
    main()

