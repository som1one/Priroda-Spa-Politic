"""
Модель пользователя
"""
from sqlalchemy import Column, String, Boolean, DateTime, Integer
from app.models.base import BaseModel


class User(BaseModel):
    """Модель пользователя"""
    __tablename__ = "users"
    
    name = Column(String(100), nullable=False)
    surname = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    avatar_url = Column(String(500), nullable=True)
    loyalty_level = Column(Integer, default=1, nullable=False)
    
    def __repr__(self):
        return f"<User {self.email}>"

