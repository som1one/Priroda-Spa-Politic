"""
Скрипт для тестирования создания приглашения админа
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.services.admin_service import AdminService
from app.models.admin import Admin, AdminRole

def test_create_invite():
    """Тест создания приглашения"""
    db: Session = SessionLocal()
    try:
        # Получаем супер-админа
        super_admin = db.query(Admin).filter(Admin.role == AdminRole.SUPER_ADMIN.value).first()
        if not super_admin:
            print("❌ Супер-админ не найден. Создайте его сначала.")
            return
        
        print(f"✅ Найден супер-админ: {super_admin.email}")
        
        # Пытаемся создать приглашение
        test_email = "test@example.com"
        print(f"\n📧 Создаю приглашение для {test_email}...")
        
        try:
            invite = AdminService.create_invite(
                db=db,
                email=test_email,
                role=AdminRole.ADMIN.value,
                invited_by=super_admin
            )
            print(f"✅ Приглашение создано успешно!")
            print(f"   Token: {invite.token[:20]}...")
            print(f"   Expires: {invite.expires_at}")
            print(f"   Role: {invite.role}")
        except Exception as e:
            print(f"❌ Ошибка создания приглашения: {e}")
            import traceback
            traceback.print_exc()
            
    finally:
        db.close()

if __name__ == "__main__":
    test_create_invite()

