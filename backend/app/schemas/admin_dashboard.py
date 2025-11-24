from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel

from app.models.booking import BookingStatus


class StatusCount(BaseModel):
    status: str
    count: int


class MonthlyBookings(BaseModel):
    month: str
    count: int


class DashboardSummaryResponse(BaseModel):
    total_users: int
    total_bookings: int
    confirmed_bookings: int
    pending_bookings: int
    status_breakdown: List[StatusCount]
    monthly_bookings: List[MonthlyBookings]


class AdminBookingResponse(BaseModel):
    id: int
    user_id: int
    client_name: Optional[str]
    client_email: Optional[str]
    service_name: str
    appointment_datetime: datetime
    status: str
    phone: Optional[str]


class AdminBookingsListResponse(BaseModel):
    items: List[AdminBookingResponse]
    total: int


class BookingUpdateRequest(BaseModel):
    status: BookingStatus
    notes: Optional[str] = None


