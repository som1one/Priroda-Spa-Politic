import logging
from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.apis.dependencies import admin_required
from app.core.database import get_db
from app.models.booking import Booking, BookingStatus
from app.models.user import User
from app.schemas.admin_dashboard import (
    DashboardSummaryResponse,
    AdminBookingsListResponse,
    AdminBookingResponse,
    StatusCount,
    MonthlyBookings,
)

router = APIRouter(prefix="/admin/dashboard", tags=["Admin Dashboard"])
logger = logging.getLogger(__name__)


@router.get("/summary", response_model=DashboardSummaryResponse)
async def dashboard_summary(
    db: Session = Depends(get_db),
    _: User = Depends(admin_required),
):
    try:
        # Оптимизируем запросы - используем один запрос для подсчёта bookings
        booking_counts = (
            db.query(Booking.status, func.count(Booking.id))
            .group_by(Booking.status)
            .all()
        )
        
        # Извлекаем данные из одного запроса
        total_bookings = sum(count for _, count in booking_counts)
        confirmed = next((count for status, count in booking_counts if status == BookingStatus.CONFIRMED), 0)
        pending = next((count for status, count in booking_counts if status == BookingStatus.PENDING), 0)
        
        status_breakdown = [
            StatusCount(status=status.value if isinstance(status, BookingStatus) else status, count=count)
            for status, count in booking_counts
        ]

        # Отдельный быстрый запрос для пользователей
        total_users = db.query(func.count(User.id)).scalar() or 0
        
        # Месячная статистика
        monthly_breakdown = _get_monthly_bookings(db)

        logger.debug("Admin summary generated")
        return DashboardSummaryResponse(
            total_users=total_users,
            total_bookings=total_bookings,
            confirmed_bookings=confirmed,
            pending_bookings=pending,
            status_breakdown=status_breakdown,
            monthly_bookings=monthly_breakdown,
        )
    except Exception as e:
        logger.error("Error generating dashboard summary", exc_info=True)
        raise


@router.get("/bookings", response_model=AdminBookingsListResponse)
async def dashboard_bookings(
    db: Session = Depends(get_db),
    _: User = Depends(admin_required),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
    status: BookingStatus | None = Query(None),
):
    query = db.query(Booking).order_by(Booking.appointment_datetime.desc())
    if status:
        query = query.filter(Booking.status == status)

    total = query.count()
    items = query.offset(offset).limit(limit).all()

    response_items = [
        AdminBookingResponse(
            id=booking.id,
            user_id=booking.user_id,
            client_name=getattr(booking.user, "name", None),
            client_email=getattr(booking.user, "email", None),
            service_name=booking.service_name,
            appointment_datetime=booking.appointment_datetime,
            status=booking.status.value,
            phone=booking.phone,
        )
        for booking in items
    ]

    return AdminBookingsListResponse(items=response_items, total=total)


def _month_floor(dt: datetime) -> datetime:
    return dt.replace(day=1, hour=0, minute=0, second=0, microsecond=0)


def _subtract_months(dt: datetime, months: int) -> datetime:
    year = dt.year
    month = dt.month - months
    while month <= 0:
        month += 12
        year -= 1
    return dt.replace(year=year, month=month)


def _get_monthly_bookings(db: Session) -> list[MonthlyBookings]:
    now = datetime.utcnow()
    start = _subtract_months(_month_floor(now), 5)

    rows = (
        db.query(func.date_trunc("month", Booking.appointment_datetime).label("month"), func.count(Booking.id))
        .filter(Booking.appointment_datetime >= start)
        .group_by("month")
        .order_by("month")
        .all()
    )

    counts_map = {
        row.month.strftime("%Y-%m"): row.count for row in rows if row.month is not None
    }

    months = []
    for i in range(5, -1, -1):
        current = _subtract_months(_month_floor(now), i)
        key = current.strftime("%Y-%m")
        months.append(MonthlyBookings(month=key, count=counts_map.get(key, 0)))

    return months


