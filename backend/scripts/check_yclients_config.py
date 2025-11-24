"""
Скрипт для проверки конфигурации YClients
"""
import sys
import os

# Добавляем корневую директорию в путь
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import settings
from app.services.yclients_service import yclients_service

def main():
    print("=" * 60)
    print("🔍 Проверка конфигурации YClients")
    print("=" * 60)
    print()
    
    # Проверка 1: YClients включен
    print("1️⃣ Проверка включения YClients...")
    if not settings.YCLIENTS_ENABLED:
        print("   ❌ YCLIENTS_ENABLED = False")
        print("   💡 Установите YCLIENTS_ENABLED=True в .env")
        return
    else:
        print("   ✅ YCLIENTS_ENABLED = True")
    print()
    
    # Проверка 2: Company ID
    print("2️⃣ Проверка Company ID...")
    if not settings.YCLIENTS_COMPANY_ID:
        print("   ❌ YCLIENTS_COMPANY_ID не установлен")
        print("   💡 Установите YCLIENTS_COMPANY_ID в .env")
        return
    else:
        print(f"   ✅ YCLIENTS_COMPANY_ID = {settings.YCLIENTS_COMPANY_ID}")
    print()
    
    # Проверка 3: API Token
    print("3️⃣ Проверка API Token...")
    if not settings.YCLIENTS_API_TOKEN:
        print("   ❌ YCLIENTS_API_TOKEN не установлен")
        print("   💡 Установите YCLIENTS_API_TOKEN в .env")
        return
    else:
        api_token_preview = settings.YCLIENTS_API_TOKEN[:20] + "..." if len(settings.YCLIENTS_API_TOKEN) > 20 else settings.YCLIENTS_API_TOKEN
        print(f"   ✅ YCLIENTS_API_TOKEN = {api_token_preview}")
    print()
    
    # Проверка 4: User Token
    print("4️⃣ Проверка User Token...")
    if not settings.YCLIENTS_USER_TOKEN:
        print("   ❌ YCLIENTS_USER_TOKEN не установлен")
        print("   💡 Установите YCLIENTS_USER_TOKEN в .env")
        print("   💡 Используйте scripts/get_yclients_user_token.py для получения токена")
        return
    else:
        user_token_preview = settings.YCLIENTS_USER_TOKEN[:20] + "..." if len(settings.YCLIENTS_USER_TOKEN) > 20 else settings.YCLIENTS_USER_TOKEN
        print(f"   ✅ YCLIENTS_USER_TOKEN = {user_token_preview}")
    print()
    
    # Проверка 5: Тест подключения
    print("5️⃣ Тест подключения к YClients API...")
    try:
        yclients_service.configure(
            company_id=settings.YCLIENTS_COMPANY_ID,
            api_token=settings.YCLIENTS_API_TOKEN,
            user_token=settings.YCLIENTS_USER_TOKEN,
        )
        
        # Пробуем получить услуги
        import asyncio
        async def test_connection():
            try:
                services = await yclients_service.get_services()
                if services:
                    print(f"   ✅ Подключение успешно! Найдено {len(services)} услуг")
                    return True
                else:
                    print("   ⚠️ Подключение успешно, но услуги не найдены")
                    return False
            except Exception as e:
                print(f"   ❌ Ошибка подключения: {e}")
                return False
        
        result = asyncio.run(test_connection())
        if not result:
            print()
            print("   💡 Проверьте:")
            print("      - Правильность Company ID")
            print("      - Правильность API Token (Partner Token)")
            print("      - Правильность User Token")
            print("      - Доступность интернета")
            return
        
    except Exception as e:
        print(f"   ❌ Ошибка настройки YClients: {e}")
        return
    
    print()
    print("=" * 60)
    print("✅ Конфигурация YClients проверена успешно!")
    print("=" * 60)
    print()
    print("📋 Следующие шаги:")
    print("   1. Синхронизируйте услуги и мастеров:")
    print("      python scripts/sync_yclients_catalog.py")
    print()
    print("   2. Настройте webhook в YClients:")
    print("      URL: https://your-domain.com/api/v1/yclients/webhook")
    print("      События: все изменения записей")
    print()
    print("   3. Проверьте работу виджета:")
    print("      - Откройте услугу в приложении")
    print("      - Нажмите 'Записаться'")
    print("      - Должен открыться виджет YClients")
    print()

if __name__ == "__main__":
    main()

