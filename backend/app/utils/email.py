"""
Утилиты для отправки email
"""
import aiosmtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings


async def send_verification_code(email: str, code: str) -> bool:
    """
    Отправка кода подтверждения на email
    
    Args:
        email: Email адрес получателя
        code: 6-значный код подтверждения
    
    Returns:
        bool: True если отправлено успешно
    """
    try:
        message = MIMEMultipart("alternative")
        message["Subject"] = "Код подтверждения SPA Salon"
        message["From"] = settings.EMAIL_FROM
        message["To"] = email
        
        # Текстовая версия письма
        text = f"""
        Добро пожаловать в SPA Salon!
        
        Ваш код подтверждения: {code}
        
        Код действителен в течение {settings.VERIFICATION_CODE_EXPIRE_MINUTES} минут.
        
        Если вы не запрашивали этот код, просто проигнорируйте это письмо.
        """
        
        # HTML версия письма
        html = f"""
        <html>
          <body>
            <h2>Добро пожаловать в SPA Salon!</h2>
            <p>Ваш код подтверждения: <strong style="font-size: 24px; color: #8B5A3C;">{code}</strong></p>
            <p>Код действителен в течение {settings.VERIFICATION_CODE_EXPIRE_MINUTES} минут.</p>
            <hr>
            <p style="color: #999; font-size: 12px;">Если вы не запрашивали этот код, просто проигнорируйте это письмо.</p>
          </body>
        </html>
        """
        
        part1 = MIMEText(text, "plain")
        part2 = MIMEText(html, "html")
        
        message.attach(part1)
        message.attach(part2)
        
        # Отправка через SMTP
        if settings.EMAIL_USE_TLS:
            await aiosmtplib.send(
                message,
                hostname=settings.EMAIL_HOST,
                port=settings.EMAIL_PORT,
                start_tls=True,
                username=settings.EMAIL_USER,
                password=settings.EMAIL_PASSWORD,
            )
        else:
            await aiosmtplib.send(
                message,
                hostname=settings.EMAIL_HOST,
                port=settings.EMAIL_PORT,
                username=settings.EMAIL_USER,
                password=settings.EMAIL_PASSWORD,
            )
        
        return True
        
    except Exception as e:
        print(f"Ошибка отправки email: {e}")
        return False

