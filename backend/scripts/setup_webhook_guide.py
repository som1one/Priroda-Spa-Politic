"""
Интерактивный скрипт для настройки webhook в YClients
Помогает сформировать правильный URL и проверить настройки
"""
import sys
import os

# Добавляем корневую директорию в путь
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import settings

def main():
    print("=" * 60)
    print("🔗 Настройка webhook в YClients")
    print("=" * 60)
    print()
    
    # Проверка конфигурации
    if not settings.YCLIENTS_ENABLED:
        print("❌ YCLIENTS_ENABLED = False")
        print("💡 Установите YCLIENTS_ENABLED=True в .env")
        return
    
    if not settings.YCLIENTS_COMPANY_ID:
        print("❌ YCLIENTS_COMPANY_ID не установлен")
        return
    
    print("✅ Конфигурация проверена")
    print()
    
    # Получаем URL для webhook
    admin_panel_url = settings.ADMIN_PANEL_BASE_URL or "http://localhost:3001"
    
    # Пытаемся определить production URL
    print("📋 Настройка webhook URL:")
    print()
    print("1️⃣ Определите ваш домен:")
    print("   - Для локальной разработки: http://localhost:9003")
    print("   - Для production: https://your-domain.com")
    print()
    
    # Запрашиваем URL у пользователя
    default_url = "https://your-domain.com"
    webhook_url = input(f"Введите URL вашего backend (по умолчанию: {default_url}): ").strip()
    if not webhook_url:
        webhook_url = default_url
    
    # Убираем слэш в конце если есть
    webhook_url = webhook_url.rstrip('/')
    
    # Формируем полный URL webhook
    full_webhook_url = f"{webhook_url}/api/v1/yclients/webhook"
    
    print()
    print("=" * 60)
    print("📝 Инструкция по настройке webhook в YClients")
    print("=" * 60)
    print()
    print("1️⃣ Войдите в админ-панель YClients:")
    print("   https://yclients.com/")
    print()
    print("2️⃣ Перейдите в настройки:")
    print("   Настройки → Интеграции → Webhooks")
    print()
    print("3️⃣ Нажмите 'Добавить webhook' или 'Создать webhook'")
    print()
    print("4️⃣ Заполните форму:")
    print(f"   URL: {full_webhook_url}")
    print("   Метод: POST")
    print("   События: Все изменения записей")
    print("   (или выберите конкретные события:")
    print("    - Создание записи")
    print("    - Изменение статуса записи")
    print("    - Отмена записи")
    print("    - Изменение даты/времени записи)")
    print()
    print("5️⃣ Сохраните webhook")
    print()
    print("=" * 60)
    print("✅ Проверка webhook")
    print("=" * 60)
    print()
    print("После настройки webhook:")
    print("1. Создайте тестовую запись в YClients")
    print("2. Проверьте логи backend на наличие webhook запросов:")
    print("   tail -f logs/app.log | grep webhook")
    print()
    print("3. Или используйте тестовый скрипт:")
    print("   python scripts/test_yclients_webhook.py")
    print()
    print("=" * 60)
    print("📋 Резюме")
    print("=" * 60)
    print()
    print(f"Webhook URL: {full_webhook_url}")
    print(f"Company ID: {settings.YCLIENTS_COMPANY_ID}")
    print()
    print("⚠️ ВАЖНО:")
    print("   - URL должен быть доступен из интернета (для production)")
    print("   - Используйте HTTPS в production")
    print("   - Проверьте, что backend запущен и доступен")
    print("   - Webhook будет работать только если backend доступен по указанному URL")
    print()
    
    # Сохраняем URL в файл для справки
    webhook_info_file = "webhook_info.txt"
    with open(webhook_info_file, "w", encoding="utf-8") as f:
        f.write(f"YClients Webhook Configuration\n")
        f.write(f"{'=' * 60}\n\n")
        f.write(f"Webhook URL: {full_webhook_url}\n")
        f.write(f"Company ID: {settings.YCLIENTS_COMPANY_ID}\n")
        f.write(f"\nСкопируйте этот URL в настройки webhook в YClients\n")
    
    print(f"💾 Информация сохранена в {webhook_info_file}")
    print()

if __name__ == "__main__":
    main()

