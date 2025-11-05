"""
API endpoints для аутентификации
"""
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.security import create_access_token, create_refresh_token
from app.core.config import settings
from app.schemas.auth import (
    RegisterRequest, LoginRequest, VerifyEmailRequest,
    ResendCodeRequest, TokenResponse, AuthResponse, GoogleLoginRequest
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
    background_tasks.add_task(send_verification_code, request.email, result["code"])
    return AuthResponse(success=True, message=result["message"], code=result.get("code"))


@router.get("/check-email")
async def check_email(email: str, db: Session = Depends(get_db)):
    """Проверка существования пользователя с указанным email"""
    user = db.query(User).filter(User.email == email).first()
    return {"exists": user is not None}


@router.post("/google", response_model=TokenResponse)
async def google_login(
    request: GoogleLoginRequest,
    db: Session = Depends(get_db)
):
    """Вход через Google"""
    try:
        from google.auth.transport import requests
        from google.oauth2 import id_token as google_id_token
        
        # Верифицируем Google ID token
        CLIENT_ID = settings.GOOGLE_CLIENT_ID
        
        if not CLIENT_ID:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Google Client ID не настроен"
            )
        
        # Верифицируем токен
        try:
            idinfo = google_id_token.verify_oauth2_token(
                request.id_token, 
                requests.Request(), 
                CLIENT_ID
            )
            
            # Проверяем, что email совпадает
            if idinfo.get('email') != request.email:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Email не совпадает с токеном"
                )
        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Неверный Google token: {str(e)}"
            )
        
        # Проверяем или создаем пользователя
        user = db.query(User).filter(User.email == request.email).first()
        
        if not user:
            # Создаем нового пользователя
            # Разделяем имя и фамилию если возможно
            name_parts = (request.name or "User").split(maxsplit=1)
            name = name_parts[0] if name_parts else "User"
            surname = name_parts[1] if len(name_parts) > 1 else ""
            
            user = User(
                email=request.email,
                name=name,
                surname=surname,
                is_verified=True,  # Google email уже подтвержден
                is_active=True,
                avatar_url=request.photo_url
            )
            db.add(user)
            db.commit()
            db.refresh(user)
        else:
            # Обновляем информацию если нужно
            if request.name:
                name_parts = request.name.split(maxsplit=1)
                if not user.name:
                    user.name = name_parts[0] if name_parts else "User"
                if not user.surname and len(name_parts) > 1:
                    user.surname = name_parts[1]
            
            if request.photo_url and not user.avatar_url:
                user.avatar_url = request.photo_url
            
            user.is_verified = True
            db.commit()
        
        # Создаем токены
        access_token = create_access_token(data={"sub": user.id})
        refresh_token = create_refresh_token(data={"sub": user.id})
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Ошибка при обработке Google авторизации: {str(e)}"
        )


@router.get("/me")
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Получить информацию о текущем пользователе"""
    return {
        "id": current_user.id,
        "name": current_user.name,
        "surname": current_user.surname,
        "email": current_user.email,
        "is_verified": current_user.is_verified,
        "avatar_url": current_user.avatar_url,
        "loyalty_level": current_user.loyalty_level
    }
