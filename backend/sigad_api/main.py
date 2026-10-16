"""API institucional. Sem endpoints de login por senha ou provisionamento público."""

from datetime import UTC

from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from .database import get_db
from .readiness import check_readiness
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


@app.get("/ready")
def readiness(db: Session = Depends(get_db)):
    """Readiness local: banco migrado e parâmetros OIDC presentes.

    Não prova conexão com o IdP, autorização de usuários ou readiness de produção.
    """
    try:
        check_readiness(db)
    except (RuntimeError, SQLAlchemyError):
        db.rollback()
        raise HTTPException(
            status_code=503,
            detail="Serviço ainda não está pronto.",
        ) from None
    return {"status": "ready"}


@app.get("/auth/me", response_model=MeRead)
def who_am_i(principal: Principal = Depends(get_principal)):
    return {
        "id": principal.subject,
        "name": principal.name,
        "email": principal.email,
        "role": principal.role,
        "expiresAt": principal.expires_at.astimezone(UTC).isoformat().replace("+00:00", "Z"),
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
