"""Limite de escrita consistente entre réplicas da API no mesmo PostgreSQL.

Consome a tentativa em transação *separada* da substituição da agenda;
até PUTs rejeitados por conflito/sem mudanças ocupam orçamento. Uma falha
de conexão ao banco nunca libera a operação (fail-closed).
"""

from fastapi import HTTPException
from sqlalchemy import text
from sqlalchemy.orm import Session

from .security import Principal

# Proteção de uso normal da agenda, não substitui rate limiting no proxy/IdP.
WRITE_ATTEMPTS_PER_MINUTE = 30

_ACQUIRE = text(
    """
    INSERT INTO public.sigad_write_rate_limits
      (actor_subject, minute_bucket, attempts)
    VALUES (
      :subject,
      floor(extract(epoch FROM statement_timestamp()) / 60)::bigint,
      1
    )
    ON CONFLICT (actor_subject, minute_bucket)
    DO UPDATE SET attempts = sigad_write_rate_limits.attempts + 1
    WHERE sigad_write_rate_limits.attempts < :max_attempts
    RETURNING attempts
    """
)


def enforce_write_limit(
    db: Session, principal: Principal, *, max_attempts: int = WRITE_ATTEMPTS_PER_MINUTE
) -> None:
    """429 em excesso; consulta atômica usa a hora do banco, nunca IP/headers."""
    if max_attempts < 1:
        raise ValueError("O limite de tentativas deve ser positivo.")
    with db.begin():
        acquired = db.execute(
            _ACQUIRE,
            {"subject": principal.subject, "max_attempts": max_attempts},
        ).scalar_one_or_none()
    if acquired is None:
        raise HTTPException(
            status_code=429,
            detail="Muitas alterações na agenda. Tente novamente em até um minuto.",
            headers={"Retry-After": "60"},
        )
