"""Validar JWT do IdP autorizado e associar papéis provisionados no banco.

Nunca aceitar role enviada pelo token como autorização de acesso: o mapeamento
institucional é mantido por administradores diretamente no PostgreSQL.
"""
from dataclasses import dataclass
from datetime import datetime, timezone
from functools import lru_cache

import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import PyJWKClient
from sqlalchemy.orm import Session

from .config import oidc_config
from .database import get_db
from .models import Member


@dataclass(frozen=True)
class Principal:
    subject: str
    name: str
    email: str
    role: str
    expires_at: datetime


@lru_cache(maxsize=1)
def jwks_client() -> PyJWKClient:
    _, _, jwks_url = oidc_config()
    return PyJWKClient(jwks_url, cache_jwk_set=True, lifespan=300)


def verify_token(token: str) -> dict:
    issuer, audience, _ = oidc_config()
    try:
        key = jwks_client().get_signing_key_from_jwt(token).key
        return jwt.decode(
            token,
            key=key,
            algorithms=["RS256"],
            audience=audience,
            issuer=issuer,
            options={"require": ["iss", "aud", "sub", "exp", "iat"]},
            leeway=30,
        )
    except (jwt.PyJWTError, ValueError, TimeoutError, OSError):
        raise HTTPException(status_code=401, detail="Credencial institucional inválida.") from None


_bearer = HTTPBearer(auto_error=False)


def get_principal(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
    db: Session = Depends(get_db),
) -> Principal:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(status_code=401, detail="Autenticação obrigatória.")
    claims = verify_token(credentials.credentials)
    subject = claims.get("sub")
    name = claims.get("name")
    email = claims.get("email")
    exp = claims.get("exp")
    if (
        not isinstance(subject, str) or not subject.strip()
        or not isinstance(name, str) or not name.strip()
        or not isinstance(email, str) or not email.strip()
        or not isinstance(exp, int)
    ):
        raise HTTPException(status_code=401, detail="Identidade institucional incompleta.")
    user = db.get(Member, subject)
    # Libera a transação de leitura de autenticação antes do FOR UPDATE da agenda.
    if user is None or not user.active:
        db.rollback()
        raise HTTPException(status_code=403, detail="Usuário não habilitado no SIGAD.")
    role = user.role
    db.rollback()
    return Principal(
        subject=subject,
        name=name.strip(),
        email=email.strip(),
        role=role,
        expires_at=datetime.fromtimestamp(exp, tz=timezone.utc),
    )


def require_reservation_access(principal: Principal) -> None:
    if principal.role not in ("professor", "coordenador", "chefeDepartamento"):
        raise HTTPException(status_code=403, detail="Perfil sem acesso às reservas.")


def require_reservation_edit(principal: Principal) -> None:
    require_reservation_access(principal)
