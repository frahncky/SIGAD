"""Prontidão é distinta de liveness e falha sem revelar detalhes internos."""

from sqlalchemy.exc import OperationalError

from sigad_api import main


def test_health_is_only_liveness(client):
    assert client.get("/health").json() == {"status": "ok"}


def test_ready_when_schema_and_oidc_are_present(client):
    response = client.get("/ready")
    assert response.status_code == 200
    assert response.json() == {"status": "ready"}


def test_ready_fails_closed_without_oidc_configuration(client, monkeypatch):
    monkeypatch.delenv("SIGAD_OIDC_ISSUER", raising=False)
    response = client.get("/ready")
    assert response.status_code == 503
    assert response.json() == {"detail": "Serviço ainda não está pronto."}


def test_ready_does_not_expose_database_errors(client, monkeypatch):
    def broken(_db):
        raise OperationalError("SELECT secret", {"password": "do-not-leak"}, Exception("fail"))

    monkeypatch.setattr(main, "check_readiness", broken)
    response = client.get("/ready")
    assert response.status_code == 503
    assert response.json() == {"detail": "Serviço ainda não está pronto."}
    assert "secret" not in response.text
    assert "do-not-leak" not in response.text
