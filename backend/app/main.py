"""
Главный файл приложения FastAPI
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

app = FastAPI(
    title="SPA Salon API",
    description="API для мобильного приложения SPA салона",
    version="1.0.0",
)

# CORS настройки для работы с Flutter приложением
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключение роутов
from app.api.v1.router import api_router
app.include_router(api_router, prefix=settings.API_V1_PREFIX)

@app.get("/")
async def root():
    return {"message": "SPA Salon API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "ok"}

