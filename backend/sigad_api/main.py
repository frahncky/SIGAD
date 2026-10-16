"""API institucional. Sem endpoints de login por senha ou provisionamento público."""
from datetime import timezone

from fastapi import Depends, FastAPI
from sqlalchemy.orm import Session

from .database import get_db
from .reservations import list_reservations, replace_reservations
from .schemas import MeRead, ReservationRead, ReservationWrite, RevisionRead
from .security import Principal, get_principal, require_reservation_access, require_reservation_edit


app = FastAPI(
    title="SIGAD — Backend de Reservas",
    description="Serviço institucional com agenda compartilhada e identidade OIDC.",
    version="0.1.0",
    docs_url=None,
    redoc_url=None,
)


@app.get("/health")
def health():
    # Não revela dados do banco, do IdP ou de usuários.
    return {"status": "ok"}


@app.get("/auth/me", response_model=MeRead)
def who_am_i(principal: Principal = Depends(get_principal)):
    return {
        "id": principal.subject,
        "name": principal.name,
        "email": principal.email,
        "role": principal.role,
        "expiresAt": principal.expires_at.astimezone(timezone.utc).isoformat().replace("+00:00", "Z"),
    }


@app.get("/laboratorios/reservas", response_model=ReservationRead)
def read_reservations(
    principal: Principal = Depends(get_principal),
    db: Session = Depends(get_db),
):
    require_reservation_access(principal)
    return list_reservations(db)


@app.put("/laboratorios/reservas", response_model=RevisionRead)
def write_reservations(
    payload: ReservationWrite,
    principal: Principal = Depends(get_principal),
    db: Session = Depends(get_db),
):
    require_reservation_edit(principal)
    return replace_reservations(db, principal, payload)
