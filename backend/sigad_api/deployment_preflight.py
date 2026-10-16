"""Pré-validação da configuração de homologação, sem acesso à rede.

A verificação é apenas sintática/de segurança local; não comprova que
endpoints sejam oficiais, acessíveis ou que a implantação esteja aprovada.
As falhas nunca incluem o conteúdo de variáveis ou senhas.
"""

import os
import sys
from collections.abc import Mapping
from urllib.parse import urlparse

from sqlalchemy.engine import make_url
from sqlalchemy.exc import ArgumentError

_REQUIRED = (
    "SIGAD_ENVIRONMENT",
    "SIGAD_DATABASE_URL",
    "SIGAD_OIDC_ISSUER",
    "SIGAD_OIDC_AUDIENCE",
    "SIGAD_OIDC_JWKS_URL",
    "SIGAD_PUBLIC_API_URL",
)
_EXAMPLE_HOSTS = {"localhost", "127.0.0.1", "::1", "db", "example.com"}
_INVALID_HOST_SUFFIXES = (".local", ".example", ".invalid", ".test")


def _real_hostname(host: str | None) -> bool:
    if not host:
        return False
    cleaned = host.lower().strip().rstrip(".")
    return (
        cleaned not in _EXAMPLE_HOSTS
        and not cleaned.startswith("exemplo.")
        and not cleaned.startswith("example.")
        and not cleaned.endswith(_INVALID_HOST_SUFFIXES)
        and "exemplo" not in cleaned
    )


def _https_address(value: str) -> bool:
    try:
        uri = urlparse(value)
        return (
            uri.scheme == "https"
            and bool(uri.netloc)
            and _real_hostname(uri.hostname)
            and uri.username is None
            and uri.password is None
            and not uri.query
            and not uri.fragment
        )
    except ValueError:
        return False


def validate_homologacao_config(environment: Mapping[str, str]) -> list[str]:
    """Retorna somente códigos de configuração, nunca seus valores."""
    missing = [name for name in _REQUIRED if not environment.get(name, "").strip()]
    if missing:
        return [f"{name}: ausente" for name in missing]

    errors = []
    if environment["SIGAD_ENVIRONMENT"].strip() != "homologacao":
        errors.append("SIGAD_ENVIRONMENT: ambiente incorreto")

    for key in ("SIGAD_OIDC_ISSUER", "SIGAD_OIDC_JWKS_URL", "SIGAD_PUBLIC_API_URL"):
        if not _https_address(environment[key].strip()):
            errors.append(f"{key}: URL HTTPS institucional inválida")

    if not environment["SIGAD_OIDC_AUDIENCE"].strip() or any(
        char.isspace() for char in environment["SIGAD_OIDC_AUDIENCE"]
    ):
        errors.append("SIGAD_OIDC_AUDIENCE: audiência inválida")

    try:
        db_url = make_url(environment["SIGAD_DATABASE_URL"].strip())
        if (
            db_url.drivername != "postgresql+psycopg"
            or not _real_hostname(db_url.host)
            or not db_url.username
            or not db_url.password
            or not db_url.database
        ):
            errors.append("SIGAD_DATABASE_URL: conexão PostgreSQL inválida")
        # Exigir validação do certificado e do hostname do banco, não apenas criptografia.
        if db_url.query.get("sslmode") != "verify-full":
            errors.append("SIGAD_DATABASE_URL: exigir sslmode=verify-full")
    except (ArgumentError, TypeError, ValueError):
        errors.append("SIGAD_DATABASE_URL: formato inválido")

    return errors


def main() -> int:
    problems = validate_homologacao_config(os.environ)
    if problems:
        print("Bloqueio de implantação: configuração de homologação incompleta ou insegura.")
        for problem in problems:
            print(f"- {problem}")
        return 2
    print(
        "Configuração local de homologação aceita. "
        "A aprovação institucional, IdP/JWKS, TLS e banco precisam ser validados."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
