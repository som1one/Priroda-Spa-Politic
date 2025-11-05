"""
Pydantic схемы для аутентификации
"""
from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional


class RegisterRequest(BaseModel):
    """Схема для регистрации"""
    name: str = Field(..., min_length=2, max_length=100)
    surname: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=100)


class LoginRequest(BaseModel):
    """Схема для входа"""
    email: EmailStr
    password: str


class VerifyEmailRequest(BaseModel):
    """Схема для подтверждения email"""
    email: EmailStr
    code: str = Field(..., min_length=6, max_length=6)


class ResendCodeRequest(BaseModel):
    """Схема для повторной отправки кода"""
    email: EmailStr


class TokenResponse(BaseModel):
    """Ответ с токеном"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class AuthResponse(BaseModel):
    """Ответ после успешной операции"""
    success: bool = True
    message: str
    user_id: Optional[int] = None
    code: Optional[str] = None  # Код подтверждения (для разработки)


class GoogleLoginRequest(BaseModel):
    """Схема для входа через Google"""
    id_token: str
    email: str
    name: Optional[str] = None
    photo_url: Optional[str] = None
