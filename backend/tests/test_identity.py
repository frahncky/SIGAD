"""Verifica autenticação, roles provisionados e JWT real assinado."""
from datetime import datetime, timedelta, timezone

import jwt
from cryptography.hazmat.primitives.asymmetric import rsa

from sigad_api.main import app
from sigad_api.models import Member
from sigad_api.security import get_principal
from sigad_api import security
from conftest import SessionForTest


def test_bearer_is_required(client):
    app.dependency_overrides.pop(get_principal, None)
    response = client.get("/auth/me")
    assert response.status_code == 401


def test_signed_token_role_mapped_from_database(client, monkeypatch):
    app.dependency_overrides.pop(get_principal, None)
    private = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    public = private.public_key()

    class LocalJwks:
        def get_signing_key_from_jwt(self, token):
            return type("SigningKey", (), {"key": public})()

    monkeypatch.setenv("SIGAD_OIDC_ISSUER", "https://idp.example.org")
    monkeypatch.setenv("SIGAD_OIDC_AUDIENCE", "sigad-api")
    monkeypatch.setenv("SIGAD_OIDC_JWKS_URL", "https://idp.example.org/jwks")
    monkeypatch.setattr(security, "jwks_client", lambda: LocalJwks())
    now = datetime.now(timezone.utc)
    claims = {
        "iss": "https://idp.example.org",
        "aud": "sigad-api",
        "sub": "ana",
        "name": "Ana",
        "email": "ana@example.edu.br",
        "role": "chefeDepartamento",  # Tentativa maliciosa: ignorada.
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(hours=1)).timestamp()),
    }
    token = jwt.encode(claims, private, algorithm="RS256")

    response = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200, response.text
    assert response.json()["role"] == "professor"
    assert response.json()["id"] == "ana"
    assert response.json()["expiresAt"].endswith("Z")

    wrong_audience = jwt.encode({**claims, "aud": "outro-app"}, private, algorithm="RS256")
    assert client.get("/auth/me", headers={"Authorization": f"Bearer {wrong_audience}"}).status_code == 401
    expired = jwt.encode({**claims, "exp": int((now - timedelta(minutes=10)).timestamp())}, private, algorithm="RS256")
    assert client.get("/auth/me", headers={"Authorization": f"Bearer {expired}"}).status_code == 401

    with SessionForTest.begin() as session:
        member = session.get(Member, "ana")
        member.active = False
    assert client.get("/auth/me", headers={"Authorization": f"Bearer {token}"}).status_code == 403


def test_no_public_provisioning_routes(client):
    assert client.post("/auth/login", json={"email": "a", "password": "b"}).status_code == 404
    assert client.post("/laboratorios", json={"name": "Fake"}).status_code == 404
