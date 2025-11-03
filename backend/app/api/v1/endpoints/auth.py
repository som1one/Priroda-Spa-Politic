"""
API endpoints для аутентификации
"""
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.schemas.auth import (
    RegisterRequest, LoginRequest, VerifyEmailRequest,
    ResendCodeRequest, TokenResponse, AuthResponse
)
from app.services.auth_service import AuthService
from app.models.user import User
from app.utils.email import send_verification_code

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=AuthResponse)
async def register(
    request: RegisterRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Регистрация нового пользователя"""
    result = await AuthService.register(db, request)
    
    # Отправка кода на email в фоне (не ждем завершения)
    background_tasks.add_task(send_verification_code, request.email, result["code"])
    
    return AuthResponse(
        success=True,
        message=result["message"],
        user_id=result["user_id"],
        code=result.get("code")  # Возвращаем код в ответе
    )


@router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """Вход пользователя"""
    return await AuthService.login(db, request.email, request.password)


@router.post("/verify-email", response_model=AuthResponse)
async def verify_email(request: VerifyEmailRequest, db: Session = Depends(get_db)):
    """Подтверждение email адреса"""
    result = await AuthService.verify_email(db, request.email, request.code)
    return AuthResponse(success=True, message=result["message"])


@router.post("/resend-code", response_model=AuthResponse)
async def resend_code(
    request: ResendCodeRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Повторная отправка кода подтверждения"""
    result = await AuthService.resend_code(db, request.email)
    
    # Отправка кода на email в фоне
    background_tasks.add_task(send_verification_code, request.email, result["code"])
    
    return AuthResponse(success=True, message=result["message"], code=result.get("code"))


@router.get("/me")
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Получить информацию о текущем пользователе"""
    return {
        "id": current_user.id,
        "name": current_user.name,
        "surname": current_user.surname,
        "email": current_user.email,
        "is_verified": current_user.is_verified,
        "avatar_url": current_user.avatar_url
    }
