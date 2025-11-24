"""
Тест правильности URL для YClients API
"""
import httpx
import asyncio
import sys
import os

# Добавляем путь к app
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from app.core.config import settings

BASE_URL = "https://api.yclients.com/api/v1"
COMPANY_ID = settings.YCLIENTS_COMPANY_ID
API_TOKEN = settings.YCLIENTS_API_TOKEN
USER_TOKEN = settings.YCLIENTS_USER_TOKEN

async def test_urls():
    """Тестируем разные варианты URL"""
    
    print("=" * 60)
    print("Тест URL для YClients API")
    print("=" * 60)
    print()
    print(f"Company ID: {COMPANY_ID}")
    print(f"API Token: {API_TOKEN[:20]}...")
    print(f"User Token: {USER_TOKEN[:20]}...")
    print()
    
    headers = {
        "Authorization": f"Bearer {API_TOKEN}",
        "User-Token": USER_TOKEN,
        "Accept": "application/vnd.api.v2+json",
        "Content-Type": "application/json",
    }
    
    # Варианты URL для тестирования
    urls_to_test = [
        f"{BASE_URL}/company/{COMPANY_ID}/services",
        f"{BASE_URL}/company/{COMPANY_ID}/services/",
        f"https://api.yclients.com/api/v1/company/{COMPANY_ID}/services",
        f"https://api.yclients.com/api/v1/company/{COMPANY_ID}/services?lang=ru",
    ]
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        for i, url in enumerate(urls_to_test, 1):
            print(f"\n{i}. Тестирую URL: {url}")
            try:
                response = await client.get(url, headers=headers)
                print(f"   Статус: {response.status_code}")
                print(f"   Ответ: {response.text[:200]}")
                
                if response.status_code == 200:
                    data = response.json()
                    if "data" in data:
                        print(f"   [OK] УСПЕХ! Найдено услуг: {len(data['data'])}")
                        print(f"   [OK] Рабочий URL: {url}")
                        return url
            except Exception as e:
                print(f"   [ERROR] Ошибка: {e}")
    
    print("\n" + "=" * 60)
    print("[WARNING] Ни один URL не сработал")
    print("=" * 60)
    return None

if __name__ == "__main__":
    asyncio.run(test_urls())

