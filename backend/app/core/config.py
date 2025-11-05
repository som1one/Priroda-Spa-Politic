"""
Конфигурация приложения
"""
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    # База данных
    DATABASE_URL: str = "postgresql://user:password@localhost:5432/spa_db"
    
    # Безопасность
    SECRET_KEY: str = "your-secret-key-change-in-production-minimum-32-characters-long"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Email
    EMAIL_HOST: str = "smtp.gmail.com"
    EMAIL_PORT: int = 587
    EMAIL_USER: str = ""
    EMAIL_PASSWORD: str = ""
    EMAIL_FROM: str = "noreply@spa-app.com"
    EMAIL_USE_TLS: bool = True
    
    # Приложение
    API_V1_PREFIX: str = "/api/v1"
    DEBUG: bool = True
    
    # CORS (парсится из строки, разделенной запятыми)
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:8080,*"
    
    @property
    def cors_origins_list(self) -> List[str]:
        """Преобразует строку CORS_ORIGINS в список"""
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    REDIS_ENABLED: bool = False
    
    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    RELOAD: bool = True
    
    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"
    
    # Verification Code
    VERIFICATION_CODE_EXPIRE_MINUTES: int = 3
    VERIFICATION_CODE_LENGTH: int = 6
    
    # Google OAuth
    GOOGLE_CLIENT_ID: str = ""
    
    # Pagination
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100
    
    # File Upload
    MAX_UPLOAD_SIZE: int = 5242880  # 5MB
    UPLOAD_DIR: str = "uploads"
    
    # Booking Settings
    MIN_BOOKING_ADVANCE_HOURS: int = 2
    MAX_BOOKING_ADVANCE_DAYS: int = 30
    CANCELLATION_HOURS_BEFORE: int = 24
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()

