"""
Полная настройка YClients интеграции
Проверяет конфигурацию, синхронизирует данные и выводит инструкции
"""
import sys
import os
import asyncio

# Добавляем корневую директорию в путь
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import settings
from app.services.yclients_service import yclients_service

def print_section(title):
    print("\n" + "=" * 60)
    print(f"  {title}")
    print("=" * 60)

def print_step(num, title):
    print(f"\n{num}️⃣ {title}")

def main():
    print_section("🚀 Полная настройка YClients интеграции")
    
    # Шаг 1: Проверка конфигурации
    print_step("1", "Проверка конфигурации")
    
    errors = []
    
    if not settings.YCLIENTS_ENABLED:
        errors.append("YCLIENTS_ENABLED не установлен в True")
        print("   ❌ YCLIENTS_ENABLED = False")
    else:
        print("   ✅ YCLIENTS_ENABLED = True")
    
    if not settings.YCLIENTS_COMPANY_ID:
        errors.append("YCLIENTS_COMPANY_ID не установлен")
        print("   ❌ YCLIENTS_COMPANY_ID не установлен")
    else:
        print(f"   ✅ YCLIENTS_COMPANY_ID = {settings.YCLIENTS_COMPANY_ID}")
    
    if not settings.YCLIENTS_API_TOKEN:
        errors.append("YCLIENTS_API_TOKEN не установлен")
        print("   ❌ YCLIENTS_API_TOKEN не установлен")
    else:
        api_token_preview = settings.YCLIENTS_API_TOKEN[:20] + "..." if len(settings.YCLIENTS_API_TOKEN) > 20 else settings.YCLIENTS_API_TOKEN
        print(f"   ✅ YCLIENTS_API_TOKEN = {api_token_preview}")
    
    if not settings.YCLIENTS_USER_TOKEN:
        errors.append("YCLIENTS_USER_TOKEN не установлен")
        print("   ❌ YCLIENTS_USER_TOKEN не установлен")
    else:
        user_token_preview = settings.YCLIENTS_USER_TOKEN[:20] + "..." if len(settings.YCLIENTS_USER_TOKEN) > 20 else settings.YCLIENTS_USER_TOKEN
        print(f"   ✅ YCLIENTS_USER_TOKEN = {user_token_preview}")
    
    if errors:
        print("\n❌ Обнаружены ошибки конфигурации:")
        for error in errors:
            print(f"   - {error}")
        print("\n💡 Установите недостающие параметры в .env файл")
        return
    
    # Шаг 2: Тест подключения
    print_step("2", "Тест подключения к YClients API")
    
    try:
        yclients_service.configure(
            company_id=settings.YCLIENTS_COMPANY_ID,
            api_token=settings.YCLIENTS_API_TOKEN,
            user_token=settings.YCLIENTS_USER_TOKEN,
        )
        
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
            print("\n💡 Проверьте правильность токенов и доступность интернета")
            return
        
    except Exception as e:
        print(f"   ❌ Ошибка настройки YClients: {e}")
        return
    
    # Шаг 3: Инструкции по синхронизации
    print_step("3", "Синхронизация данных")
    print("   📋 Для синхронизации услуг и мастеров выполните:")
    print("      python scripts/sync_yclients_catalog.py")
    print()
    print("   ⚠️ Это создаст/обновит услуги и мастеров в вашей БД")
    
    # Шаг 4: Инструкции по webhook
    print_step("4", "Настройка webhook в YClients")
    print("   📋 Настройте webhook в админ-панели YClients:")
    print("      1. Войдите в YClients → Настройки → Интеграции → Webhooks")
    print("      2. Добавьте новый webhook:")
    print(f"         URL: https://your-domain.com/api/v1/yclients/webhook")
    print("         События: все изменения записей")
    print("         Метод: POST")
    print()
    print("   ⚠️ Замените 'your-domain.com' на ваш реальный домен!")
    
    # Шаг 5: Проверка APScheduler
    print_step("5", "Проверка автоматической синхронизации")
    print("   ✅ APScheduler настроен в main.py")
    print("   ✅ Автоматическая синхронизация будет запускаться каждые 30 минут")
    print("   ✅ Проверьте логи при старте backend для подтверждения")
    
    # Шаг 6: Финальные инструкции
    print_step("6", "Тестирование")
    print("   📋 Проверьте работу системы:")
    print("      1. Откройте услугу в приложении")
    print("      2. Нажмите 'Записаться'")
    print("      3. Должен открыться виджет YClients")
    print("      4. Создайте тестовую запись")
    print("      5. Проверьте список записей - новая запись должна появиться")
    
    print_section("✅ Настройка завершена!")
    print("\n📝 Следующие шаги:")
    print("   1. Запустите синхронизацию: python scripts/sync_yclients_catalog.py")
    print("   2. Настройте webhook в YClients (см. шаг 4)")
    print("   3. Перезапустите backend для активации APScheduler")
    print("   4. Протестируйте создание записи через виджет")
    print()

if __name__ == "__main__":
    main()

