import logging

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, or_
from sqlalchemy.orm import Session

from app.apis.dependencies import admin_required
from app.core.database import get_db
from app.models.booking import Booking, BookingStatus
from app.models.user import User
from app.schemas.admin_dashboard import (
    AdminBookingsListResponse,
    AdminBookingResponse,
    BookingUpdateRequest,
)

router = APIRouter(prefix="/admin/bookings", tags=["Admin Bookings"])
logger = logging.getLogger(__name__)


@router.get("", response_model=AdminBookingsListResponse)
async def list_bookings(
    db: Session = Depends(get_db),
    _: dict = Depends(admin_required),
    status: BookingStatus | None = Query(None),
    search: str | None = Query(None, description="Имя клиента или услуга"),
    user_id: int | None = Query(None),
    date_from: str | None = Query(None, description="Дата от (ISO)"),
    date_to: str | None = Query(None, description="Дата до (ISO)"),
    limit: int = Query(25, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    query = db.query(Booking).join(User, Booking.user_id == User.id)
    if status:
        query = query.filter(Booking.status == status)
    if search:
        like = f"%{search.lower()}%"
        query = query.filter(
            or_(
                func.lower(Booking.service_name).like(like),
                func.lower(User.name).like(like),
                func.lower(User.email).like(like),
            )
        )
    if user_id:
        query = query.filter(Booking.user_id == user_id)
    if date_from:
        query = query.filter(Booking.appointment_datetime >= date_from)
    if date_to:
        query = query.filter(Booking.appointment_datetime <= date_to)

    total = query.count()
    items = (
        query.order_by(Booking.appointment_datetime.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )

    responses = []
    for booking in items:
        responses.append(
            AdminBookingResponse(
                id=booking.id,
                user_id=booking.user_id,
                client_name=getattr(booking.user, "name", None),
                client_email=getattr(booking.user, "email", None),
                service_name=booking.service_name,
                appointment_datetime=booking.appointment_datetime,
                status=booking.status.value,
                phone=booking.phone or getattr(booking.user, "phone", None),
            )
        )

    return AdminBookingsListResponse(items=responses, total=total)


@router.patch("/{booking_id}", response_model=AdminBookingResponse)
async def update_booking(
    booking_id: int,
    payload: BookingUpdateRequest,
    db: Session = Depends(get_db),
    _: dict = Depends(admin_required),
):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Бронь не найдена")

    booking.status = payload.status
    if payload.notes is not None:
        booking.notes = payload.notes
    db.commit()
    db.refresh(booking)
    logger.info("Admin updated booking", extra={"booking_id": booking.id})
    return AdminBookingResponse.model_validate(booking)

