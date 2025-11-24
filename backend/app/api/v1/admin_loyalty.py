"""
Админские API для управления программой лояльности
"""
import logging
from typing import List
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.apis.dependencies import admin_required
from app.core.database import get_db
from app.models.loyalty import LoyaltyLevel, LoyaltyBonus
from app.models.user import User
from app.schemas.loyalty import (
    LoyaltyLevelResponse,
    LoyaltyLevelCreate,
    LoyaltyLevelUpdate,
    LoyaltyBonusResponse,
    LoyaltyBonusCreate,
    LoyaltyBonusUpdate,
)
from app.services.audit_service import AuditService

router = APIRouter(prefix="/admin/loyalty", tags=["Admin Loyalty"])
logger = logging.getLogger(__name__)


# Уровни лояльности
@router.get("/levels", response_model=List[LoyaltyLevelResponse])
async def list_loyalty_levels(
    db: Session = Depends(get_db),
    _: dict = Depends(admin_required),
):
    """Список уровней лояльности"""
    levels = (
        db.query(LoyaltyLevel)
        .order_by(LoyaltyLevel.order_index.asc(), LoyaltyLevel.min_bonuses.asc())
        .all()
    )
    return [LoyaltyLevelResponse.model_validate(level) for level in levels]


@router.post("/levels", response_model=LoyaltyLevelResponse, status_code=status.HTTP_201_CREATED)
async def create_loyalty_level(
    payload: LoyaltyLevelCreate,
    http_request: Request,
    db: Session = Depends(get_db),
    admin=Depends(admin_required),
):
    """Создать уровень лояльности"""
    level_data = payload.model_dump()
    # cashback_percent устанавливается автоматически и не редактируется через API
    # При создании нового уровня устанавливаем минимальный процент (3%)
    if 'cashback_percent' not in level_data:
        level_data['cashback_percent'] = 3
    
    level = LoyaltyLevel(**level_data)
    db.add(level)
    db.commit()
    db.refresh(level)
    
    AuditService.log_action(
        db,
        admin_id=admin.id,
        action="create_loyalty_level",
        entity="loyalty_level",
        entity_id=level.id,
        payload=payload.model_dump(),
        request=http_request,
    )
    
    return LoyaltyLevelResponse.model_validate(level)


@router.patch("/levels/{level_id}", response_model=LoyaltyLevelResponse)
async def update_loyalty_level(
    level_id: int,
    payload: LoyaltyLevelUpdate,
    http_request: Request,
    db: Session = Depends(get_db),
    admin=Depends(admin_required),
):
    """Обновить уровень лояльности"""
    level = db.query(LoyaltyLevel).filter(LoyaltyLevel.id == level_id).first()
    if not level:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Уровень не найден")
    
    update_data = payload.model_dump(exclude_unset=True)
    # cashback_percent не редактируется через API, исключаем его из обновления
    update_data.pop('cashback_percent', None)
    for field, value in update_data.items():
        setattr(level, field, value)
    
    db.commit()
    db.refresh(level)
    
    AuditService.log_action(
        db,
        admin_id=admin.id,
        action="update_loyalty_level",
        entity="loyalty_level",
        entity_id=level.id,
        payload=update_data,
        request=http_request,
    )
    
    return LoyaltyLevelResponse.model_validate(level)


@router.delete("/levels/{level_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_loyalty_level(
    level_id: int,
    http_request: Request,
    db: Session = Depends(get_db),
    admin=Depends(admin_required),
):
    """Удалить уровень лояльности"""
    level = db.query(LoyaltyLevel).filter(LoyaltyLevel.id == level_id).first()
    if not level:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Уровень не найден")
    
    db.delete(level)
    db.commit()
    
    AuditService.log_action(
        db,
        admin_id=admin.id,
        action="delete_loyalty_level",
        entity="loyalty_level",
        entity_id=level_id,
        request=http_request,
    )


# Бонусы
@router.get("/bonuses", response_model=List[LoyaltyBonusResponse])
async def list_loyalty_bonuses(
    db: Session = Depends(get_db),
    _: dict = Depends(admin_required),
):
    """Список бонусов"""
    bonuses = (
        db.query(LoyaltyBonus)
        .order_by(LoyaltyBonus.order_index.asc(), LoyaltyBonus.id.asc())
        .all()
    )
    return [LoyaltyBonusResponse.model_validate(bonus) for bonus in bonuses]


@router.post("/bonuses", response_model=LoyaltyBonusResponse, status_code=status.HTTP_201_CREATED)
async def create_loyalty_bonus(
    payload: LoyaltyBonusCreate,
    http_request: Request,
    db: Session = Depends(get_db),
    admin=Depends(admin_required),
):
    """Создать бонус"""
    bonus = LoyaltyBonus(**payload.model_dump())
    db.add(bonus)
    db.commit()
    db.refresh(bonus)
    
    AuditService.log_action(
        db,
        admin_id=admin.id,
        action="create_loyalty_bonus",
        entity="loyalty_bonus",
        entity_id=bonus.id,
        payload=payload.model_dump(),
        request=http_request,
    )
    
    return LoyaltyBonusResponse.model_validate(bonus)


@router.patch("/bonuses/{bonus_id}", response_model=LoyaltyBonusResponse)
async def update_loyalty_bonus(
    bonus_id: int,
    payload: LoyaltyBonusUpdate,
    http_request: Request,
    db: Session = Depends(get_db),
    admin=Depends(admin_required),
):
    """Обновить бонус"""
    bonus = db.query(LoyaltyBonus).filter(LoyaltyBonus.id == bonus_id).first()
    if not bonus:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Бонус не найден")
    
    update_data = payload.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(bonus, field, value)
    
    db.commit()
    db.refresh(bonus)
    
    AuditService.log_action(
        db,
        admin_id=admin.id,
        action="update_loyalty_bonus",
        entity="loyalty_bonus",
        entity_id=bonus.id,
        payload=update_data,
        request=http_request,
    )
    
    return LoyaltyBonusResponse.model_validate(bonus)


@router.delete("/bonuses/{bonus_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_loyalty_bonus(
    bonus_id: int,
    http_request: Request,
    db: Session = Depends(get_db),
    admin=Depends(admin_required),
):
    """Удалить бонус"""
    bonus = db.query(LoyaltyBonus).filter(LoyaltyBonus.id == bonus_id).first()
    if not bonus:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Бонус не найден")
    
    db.delete(bonus)
    db.commit()
    
    AuditService.log_action(
        db,
        admin_id=admin.id,
        action="delete_loyalty_bonus",
        entity="loyalty_bonus",
        entity_id=bonus_id,
        request=http_request,
    )


class LoyaltyAdjustRequest(BaseModel):
    """Запрос на изменение бонусов пользователя"""
    bonuses_delta: int
    reason: str | None = None


@router.post("/users/{user_id}/adjust")
async def adjust_user_loyalty_bonuses(
    user_id: int,
    payload: LoyaltyAdjustRequest,
    http_request: Request,
    db: Session = Depends(get_db),
    admin=Depends(admin_required),
):
    """
    Ручная корректировка бонусов лояльности пользователя из админки.

    Можно как добавить (+N), так и списать (−N) бонусы.
    При списании бонусов (отрицательное значение) увеличивается spent_bonuses.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Пользователь не найден")

    current_bonuses = user.loyalty_bonuses or 0
    bonuses_delta = payload.bonuses_delta
    
    # Проверяем, что не списываем больше, чем есть
    if bonuses_delta < 0 and abs(bonuses_delta) > current_bonuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Недостаточно бонусов. У пользователя {current_bonuses} бонусов, пытаетесь списать {abs(bonuses_delta)}"
        )
    
    new_bonuses = max(0, current_bonuses + bonuses_delta)
    user.loyalty_bonuses = new_bonuses
    
    # Если списываем бонусы, увеличиваем spent_bonuses
    if bonuses_delta < 0:
        user.spent_bonuses = (user.spent_bonuses or 0) + abs(bonuses_delta)
    
    # Обновляем уровень лояльности на основе новых бонусов
    from app.services.loyalty_service import _get_user_loyalty_level
    new_level = _get_user_loyalty_level(db, user)
    if new_level:
        user.loyalty_level_id = new_level.id

    db.commit()
    db.refresh(user)

    AuditService.log_action(
        db,
        admin_id=admin.id,
        action="adjust_loyalty_bonuses",
        entity="user",
        entity_id=user.id,
        payload={
            "delta": bonuses_delta,
            "reason": payload.reason,
            "old_bonuses": current_bonuses,
            "new_bonuses": new_bonuses,
            "spent_bonuses": user.spent_bonuses,
        },
        request=http_request,
    )

    return {
        "success": True,
        "user_id": user.id,
        "current_bonuses": new_bonuses,
        "spent_bonuses": user.spent_bonuses,
    }


@router.get("/users/by-code/{unique_code}")
async def get_user_by_code(
    unique_code: str,
    db: Session = Depends(get_db),
    _: dict = Depends(admin_required),
):
    """
    Найти пользователя по уникальному коду.
    
    Используется для быстрого поиска пользователя в админ панели
    при списании бонусов по коду.
    """
    user = db.query(User).filter(User.unique_code == unique_code.upper()).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Пользователь с кодом {unique_code} не найден"
        )
    
    from app.schemas.admin_users import AdminUserResponse
    return AdminUserResponse.model_validate(user)


class LoyaltySettingsResponse(BaseModel):
    """Настройки программы лояльности"""
    loyalty_enabled: bool
    points_per_100_rub: int


class LoyaltySettingsUpdate(BaseModel):
    """Обновление настроек программы лояльности"""
    points_per_100_rub: int


@router.get("/settings", response_model=LoyaltySettingsResponse)
async def get_loyalty_settings(
    _: dict = Depends(admin_required),
):
    """Получить текущие настройки программы лояльности"""
    from app.core.config import settings
    return LoyaltySettingsResponse(
        loyalty_enabled=settings.LOYALTY_ENABLED,
        points_per_100_rub=settings.LOYALTY_POINTS_PER_100_RUB,
    )


@router.patch("/settings")
async def update_loyalty_settings(
    payload: LoyaltySettingsUpdate,
    http_request: Request,
    admin=Depends(admin_required),
):
    """
    Обновить настройки программы лояльности.
    
    ВНИМАНИЕ: Это обновляет только runtime-значение настроек.
    После перезапуска сервера значения вернутся к тем, что в .env/.env.local
    """
    from app.core.config import settings
    
    if payload.points_per_100_rub < 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Количество баллов не может быть отрицательным"
        )
    
    old_value = settings.LOYALTY_POINTS_PER_100_RUB
    settings.LOYALTY_POINTS_PER_100_RUB = payload.points_per_100_rub
    
    logger.info(
        "Обновлены настройки лояльности",
        extra={
            "admin_id": admin.id,
            "old_points_per_100": old_value,
            "new_points_per_100": payload.points_per_100_rub,
        },
    )
    
    return {
        "success": True,
        "points_per_100_rub": payload.points_per_100_rub,
        "note": "Изменения применены. После перезапуска сервера настройки вернутся к значениям из .env"
    }

