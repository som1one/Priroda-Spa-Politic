"""
Главный роутер API v1
"""
from fastapi import APIRouter
from app.api.v1.endpoints import auth, bookings

api_router = APIRouter()

# Подключаем все endpoints
api_router.include_router(
    auth.router,
    tags=["Authentication"]
)

api_router.include_router(
    bookings.router,
    tags=["Bookings"]
)

