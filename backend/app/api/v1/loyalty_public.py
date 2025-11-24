"""
Публичные API для программы лояльности
"""
import logging
from sqlalchemy.orm import Session
from fastapi import APIRouter, Depends, HTTPException
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.models.loyalty import LoyaltyLevel, LoyaltyBonus
from pydantic import BaseModel
from app.schemas.loyalty import LoyaltyInfoResponse, LoyaltyLevelResponse, LoyaltyBonusResponse

router = APIRouter(prefix="/loyalty", tags=["Loyalty"])
logger = logging.getLogger(__name__)


class UpdateAutoApplyRequest(BaseModel):
    auto_apply: bool


@router.get("/info", response_model=LoyaltyInfoResponse)
async def get_loyalty_info(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Получить информацию о лояльности текущего пользователя"""
    bonuses = user.loyalty_bonuses or 0
    spent_bonuses = user.spent_bonuses or 0
    
    # Находим текущий уровень
    current_level = (
        db.query(LoyaltyLevel)
        .filter(
            LoyaltyLevel.is_active == True,
            LoyaltyLevel.min_bonuses <= bonuses,
        )
        .order_by(LoyaltyLevel.min_bonuses.desc())
        .first()
    )
    
    # Находим следующий уровень
    next_level = None
    if current_level:
        next_level = (
            db.query(LoyaltyLevel)
            .filter(
                LoyaltyLevel.is_active == True,
                LoyaltyLevel.min_bonuses > current_level.min_bonuses,
            )
            .order_by(LoyaltyLevel.min_bonuses.asc())
            .first()
        )
    else:
        # Если нет текущего уровня, берём первый
        next_level = (
            db.query(LoyaltyLevel)
            .filter(LoyaltyLevel.is_active == True)
            .order_by(LoyaltyLevel.min_bonuses.asc())
            .first()
        )
    
    # Рассчитываем прогресс
    bonuses_to_next = 0
    progress = 0.0
    if current_level and next_level:
        bonuses_to_next = next_level.min_bonuses - bonuses
        range_bonuses = next_level.min_bonuses - current_level.min_bonuses
        if range_bonuses > 0:
            progress = max(0.0, min(1.0, (bonuses - current_level.min_bonuses) / range_bonuses))
    elif not current_level and next_level:
        bonuses_to_next = next_level.min_bonuses - bonuses
        if next_level.min_bonuses > 0:
            progress = max(0.0, min(1.0, bonuses / next_level.min_bonuses))
        else:
            progress = 0.0
    
    # Получаем доступные бонусы
    # Бонусы, которые доступны для текущего уровня или ниже
    available_bonuses = []
    if current_level:
        bonuses_list = (
            db.query(LoyaltyBonus)
            .filter(
                LoyaltyBonus.is_active == True,
                (LoyaltyBonus.min_level_id.is_(None)) | (LoyaltyBonus.min_level_id <= current_level.id),
            )
            .order_by(LoyaltyBonus.order_index.asc(), LoyaltyBonus.id.asc())
            .all()
        )
        available_bonuses = [LoyaltyBonusResponse.model_validate(b) for b in bonuses_list]
    
    return LoyaltyInfoResponse(
        current_bonuses=bonuses,
        spent_bonuses=spent_bonuses,
        current_level=LoyaltyLevelResponse.model_validate(current_level) if current_level else None,
        next_level=LoyaltyLevelResponse.model_validate(next_level) if next_level else None,
        bonuses_to_next=max(0, bonuses_to_next),
        progress=progress,
        available_bonuses=available_bonuses,
    )


@router.patch("/auto-apply")
async def update_auto_apply_loyalty(
    payload: UpdateAutoApplyRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Обновить настройку автоматического применения баллов лояльности"""
    user.auto_apply_loyalty_points = payload.auto_apply
    db.commit()
    db.refresh(user)
    logger.info("Обновлена настройка auto_apply_loyalty_points", extra={"user_id": user.id, "value": payload.auto_apply})
    return {"success": True, "auto_apply_loyalty_points": user.auto_apply_loyalty_points}

