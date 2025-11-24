"""
Скрипт для тестирования webhook от YClients
Имитирует запрос webhook для проверки обработки
"""
import sys
import os
import asyncio
import httpx

# Добавляем корневую директорию в путь
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import settings

def main():
    print("=" * 60)
    print("🧪 Тест webhook от YClients")
    print("=" * 60)
    print()
    
    if not settings.YCLIENTS_ENABLED:
        print("❌ YCLIENTS_ENABLED = False")
        print("💡 Установите YCLIENTS_ENABLED=True в .env")
        return
    
    # Получаем URL backend
    backend_url = os.getenv("BACKEND_URL", "http://localhost:9003")
    webhook_url = f"{backend_url}/api/v1/yclients/webhook"
    
    print(f"📋 Отправка тестового webhook на {webhook_url}")
    print()
    
    # Пример payload от YClients
    test_payload = {
        "event": "record_created",
        "data": {
            "id": 123456,  # Замените на реальный ID записи для теста
            "date": "2025-01-15",
            "time": "14:00",
            "status": "confirmed",
            "client": {
                "name": "Тестовый Клиент",
                "email": "test@example.com",  # Замените на email существующего пользователя
                "phone": "+79991234567",  # Замените на телефон существующего пользователя
            },
            "services": [
                {
                    "title": "Тестовая услуга",
                    "price_min": 1000.0,
                    "length": 60,
                }
            ],
        }
    }
    
    print("📤 Payload:")
    import json
    print(json.dumps(test_payload, indent=2, ensure_ascii=False))
    print()
    
    print("⚠️ ВНИМАНИЕ: Убедитесь, что:")
    print("   1. Backend запущен")
    print("   2. В payload указан реальный ID записи из YClients (если есть)")
    print("   3. В payload указан email или телефон существующего пользователя")
    print()
    
    response = input("Продолжить? (y/n): ")
    if response.lower() != 'y':
        print("Отменено")
        return
    
    try:
        async def send_webhook():
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    webhook_url,
                    json=test_payload,
                    headers={"Content-Type": "application/json"},
                )
                print()
                print(f"📥 Ответ от сервера:")
                print(f"   Status: {response.status_code}")
                print(f"   Response: {response.text}")
                return response.status_code == 200
        
        result = asyncio.run(send_webhook())
        if result:
            print()
            print("✅ Webhook успешно обработан!")
        else:
            print()
            print("❌ Ошибка обработки webhook. Проверьте логи backend.")
    except Exception as e:
        print(f"❌ Ошибка отправки webhook: {e}")
        print()
        print("💡 Проверьте:")
        print("   1. Backend запущен и доступен")
        print("   2. URL правильный")
        print("   3. Нет проблем с сетью")
    
    print()
    print("=" * 60)
    print("✅ Тестирование завершено!")
    print("=" * 60)

if __name__ == "__main__":
    main()

