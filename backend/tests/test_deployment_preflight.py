"""Segurança da pré-validação: falha sem segredos nos erros."""

from sigad_api.deployment_preflight import validate_homologacao_config


def _valid() -> dict[str, str]:
    return {
        "SIGAD_ENVIRONMENT": "homologacao",
        "SIGAD_DATABASE_URL": (
            "postgresql+psycopg://conta:SEGREDO@postgres.instituicao.edu.br:5432/sigad"
            "?sslmode=verify-full&sslrootcert=/etc/ssl/certs/ca-certificates.crt"
        ),
        "SIGAD_OIDC_ISSUER": "https://identidade.instituicao.edu.br/realms/sigad",
        "SIGAD_OIDC_AUDIENCE": "sigad-api",
        "SIGAD_OIDC_JWKS_URL": "https://identidade.instituicao.edu.br/certs",
        "SIGAD_PUBLIC_API_URL": "https://sigad-api.instituicao.edu.br",
    }


def test_accepts_structurally_secure_staging_settings():
    assert validate_homologacao_config(_valid()) == []


def test_missing_configuration_blocks_start():
    result = validate_homologacao_config({})
    assert len(result) == 6
    assert "SIGAD_DATABASE_URL: ausente" in result


def test_refuses_local_database_and_no_verified_tls():
    config = _valid()
    config["SIGAD_DATABASE_URL"] = "postgresql+psycopg://u:SENHA@db:5432/sigad"
    result = validate_homologacao_config(config)
    assert "SIGAD_DATABASE_URL: conexão PostgreSQL inválida" in result
    assert "SIGAD_DATABASE_URL: exigir sslmode=verify-full" in result
    assert "SENHA" not in str(result)


def test_refuses_example_hosts_and_http_issuer():
    config = _valid()
    config["SIGAD_OIDC_ISSUER"] = "http://idp.instituicao.edu.br"
    config["SIGAD_OIDC_JWKS_URL"] = "https://idp.exemplo.edu.br/jwks"
    config["SIGAD_PUBLIC_API_URL"] = "https://api.sigad.local"
    result = validate_homologacao_config(config)
    assert len(result) == 3


def test_catches_invalid_database_url_without_echoing_secrets():
    config = _valid()
    config["SIGAD_DATABASE_URL"] = "password://SEGREDO.example"
    problems = validate_homologacao_config(config)
    assert problems
    assert "SEGREDO" not in str(problems)


def test_refuses_bad_environment_and_invalid_audience():
    config = _valid()
    config["SIGAD_ENVIRONMENT"] = "prod"
    config["SIGAD_OIDC_AUDIENCE"] = "bearer sigad"
    result = validate_homologacao_config(config)
    assert "SIGAD_ENVIRONMENT: ambiente incorreto" in result
    assert "SIGAD_OIDC_AUDIENCE: audiência inválida" in result
