"""Configuração obrigatória, sem credenciais ou IdP demonstrativos."""
import os
from urllib.parse import urlparse


def required(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise RuntimeError(f"Configuração obrigatória ausente: {name}")
    return value


def database_url() -> str:
    url = required("SIGAD_DATABASE_URL")
    if not url.startswith(("postgresql+psycopg://", "postgresql://")):
        raise RuntimeError("SIGAD_DATABASE_URL deve usar PostgreSQL")
    return url


def oidc_config() -> tuple[str, str, str]:
    issuer = required("SIGAD_OIDC_ISSUER")
    audience = required("SIGAD_OIDC_AUDIENCE")
    jwks_url = required("SIGAD_OIDC_JWKS_URL")
    for name, value in (("issuer", issuer), ("JWKS", jwks_url)):
        parsed = urlparse(value)
        if parsed.scheme != "https" or not parsed.netloc or parsed.username or parsed.password:
            raise RuntimeError(f"OIDC {name} deve usar URL HTTPS válida")
    return issuer, audience, jwks_url
