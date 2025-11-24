"""Utility script to test SMTP email sending."""
import asyncio
from datetime import datetime

from app.core.config import settings
from app.utils.email import send_booking_confirmation, send_verification_code


async def main() -> None:
    print("Current SMTP configuration:")
    print(f"  HOST: {settings.EMAIL_HOST}:{settings.EMAIL_PORT}")
    print(f"  USER: {settings.EMAIL_USER}")
    print(f"  USE_TLS: {settings.EMAIL_USE_TLS}")
    print(f"  USE_SSL: {settings.EMAIL_USE_SSL}")
    print(f"  FROM: {settings.EMAIL_FROM}")

    target_email = 'farm49595@gmail.com'
    print(f"\nSending test verification code to: {target_email}")
    ok_verification = await send_verification_code(target_email, "123456")
    print(f"Verification email sent: {ok_verification}")

    print("\nSending test booking confirmation...")
    ok_booking = await send_booking_confirmation(
        email=target_email,
        service_name="Тестовая услуга",
        appointment_datetime=datetime.utcnow(),
        service_price=7500,
        service_duration=90,
    )
    print(f"Booking confirmation sent: {ok_booking}")


if __name__ == "__main__":
    asyncio.run(main())
