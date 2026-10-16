"""Validação restrita de dependências para probes de prontidão.

O status 200 NÃO garante conectividade do IdP/JWKS nem homologação institucional.
Nunca divulga credenciais, hosts ou erros do banco na resposta pública.
"""

from sqlalchemy import text
from sqlalchemy.orm import Session

from .config import oidc_config

_TABLES = (
    "sigad_members",
    "sigad_laboratories",
    "sigad_reservation_revision",
    "sigad_reservations",
    "sigad_reservation_audit",
    "sigad_write_rate_limits",
)


def check_readiness(db: Session) -> None:
    """Falha se a configuração obrigatória ou as migrações estiverem ausentes."""
    oidc_config()
    # Testar em uma transação só; o banco continua sendo a fonte de verdade.
    for table in _TABLES:
        exists = db.execute(
            text("SELECT to_regclass(:table_name) IS NOT NULL"),
            {"table_name": f"public.{table}"},
        ).scalar_one()
        if not exists:
            raise RuntimeError("Esquema da agenda não inicializado.")
    revision = db.execute(
        text("SELECT value FROM sigad_reservation_revision WHERE id = 1")
    ).scalar_one_or_none()
    if revision is None or revision < 0:
        raise RuntimeError("Revisão inicial da agenda não provisionada.")
