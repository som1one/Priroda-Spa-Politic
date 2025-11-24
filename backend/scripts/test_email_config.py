"""
Скрипт для тестирования настроек email
"""
import sys
import os
import asyncio

# Устанавливаем рабочую директорию на backend/ перед импортом settings
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(backend_dir)
sys.path.insert(0, backend_dir)

# Явно загружаем .env файл
env_path = os.path.join(backend_dir, ".env")
if os.path.exists(env_path):
    try:
        with open(env_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                if '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip()
                    if value.startswith('"') and value.endswith('"'):
                        value = value[1:-1]
                    elif value.startswith("'") and value.endswith("'"):
                        value = value[1:-1]
                    if key and value:
                        os.environ[key] = value
    except Exception as e:
        print(f"[WARNING] Ошибка чтения .env: {e}")

from app.core.config import settings
from app.utils.email import _validate_email_settings, _get_smtp_settings
import aiosmtplib
from email.mime.text import MIMEText


async def test_smtp_connection():
    """Тестирование подключения к SMTP серверу"""
    print("=" * 60)
    print("Тестирование настроек Email")
    print("=" * 60)
    
    # Проверка настроек
    try:
        _validate_email_settings()
        print("\n✅ Все обязательные настройки установлены")
    except ValueError as e:
        print(f"\n❌ Ошибка конфигурации: {e}")
        return False
    
    print(f"\n📧 Настройки SMTP:")
    print(f"   Host: {settings.EMAIL_HOST}")
    print(f"   Port: {settings.EMAIL_PORT}")
    print(f"   User: {settings.EMAIL_USER}")
    print(f"   From: {settings.EMAIL_FROM or settings.EMAIL_USER}")
    print(f"   Use TLS: {settings.EMAIL_USE_TLS}")
    print(f"   Use SSL: {settings.EMAIL_USE_SSL}")
    
    # Получаем правильные настройки SMTP
    smtp_settings = _get_smtp_settings()
    print(f"\n🔧 Применяемые настройки:")
    print(f"   start_tls: {smtp_settings['start_tls']}")
    print(f"   use_tls: {smtp_settings['use_tls']}")
    
    # Тестируем подключение
    print(f"\n🔌 Тестирование подключения к SMTP серверу...")
    try:
        async with aiosmtplib.SMTP(
            hostname=smtp_settings['hostname'],
            port=smtp_settings['port'],
        ) as smtp:
            if smtp_settings['start_tls']:
                await smtp.starttls()
            
            await smtp.login(
                smtp_settings['username'],
                smtp_settings['password']
            )
            
            print("✅ Подключение и аутентификация успешны!")
            
            # Отправляем тестовое письмо
            print(f"\n📨 Отправка тестового письма на {settings.EMAIL_USER}...")
            test_message = MIMEText("Это тестовое письмо для проверки настроек email.", "plain", "utf-8")
            test_message["Subject"] = "Тест настроек Email - PRIRODA SPA"
            test_message["From"] = smtp_settings['sender']
            test_message["To"] = settings.EMAIL_USER
            
            await smtp.send_message(test_message)
            print("✅ Тестовое письмо отправлено!")
            
            return True
            
    except aiosmtplib.errors.SMTPAuthenticationError as e:
        print(f"\n❌ Ошибка аутентификации SMTP:")
        print(f"   {e}")
        print(f"\n💡 Решения:")
        print(f"   1. Проверьте EMAIL_USER и EMAIL_PASSWORD в .env")
        print(f"   2. Для Gmail используйте App Password, а не обычный пароль")
        print(f"   3. Создайте App Password: https://myaccount.google.com/apppasswords")
        print(f"   4. Убедитесь, что в аккаунте Google включен доступ для 'ненадежных приложений'")
        return False
    except Exception as e:
        print(f"\n❌ Ошибка подключения:")
        print(f"   {type(e).__name__}: {e}")
        print(f"\n💡 Проверьте:")
        print(f"   1. Правильность EMAIL_HOST и EMAIL_PORT")
        print(f"   2. Доступность SMTP сервера")
        print(f"   3. Настройки файрвола")
        return False


def main():
    print("\n" + "=" * 60)
    print("ТЕСТИРОВАНИЕ НАСТРОЕК EMAIL")
    print("=" * 60 + "\n")
    print(f"Рабочая директория: {os.getcwd()}")
    print(f"Путь к .env: {env_path}")
    print(f"Существует: {'Да' if os.path.exists(env_path) else 'Нет'}")
    print()
    
    result = asyncio.run(test_smtp_connection())
    
    print("\n" + "=" * 60)
    if result:
        print("✅ Тестирование завершено успешно")
    else:
        print("❌ Тестирование завершено с ошибками")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    main()

