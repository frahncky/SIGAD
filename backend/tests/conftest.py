"""Os testes exigem PostgreSQL REAL e nunca usam banco de produção."""
import os
from datetime import datetime, timedelta, timezone

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session, sessionmaker

os.environ.setdefault(
    "SIGAD_DATABASE_URL",
    "postgresql+psycopg://sigad_test:sigad_test@127.0.0.1:5432/sigad_test",
)

from sigad_api.database import get_db  # noqa: E402
from sigad_api.main import app  # noqa: E402
from sigad_api.models import Laboratory, Member  # noqa: E402
from sigad_api.security import Principal, get_principal  # noqa: E402


URL = os.environ["SIGAD_DATABASE_URL"]
assert URL.rsplit("/", 1)[-1] == "sigad_test", "Testes não podem limpar banco não dedicado."
engine = create_engine(URL, pool_size=5, max_overflow=5)
SessionForTest = sessionmaker(bind=engine, expire_on_commit=False)


def identity(subject="ana", name="Ana", role="professor") -> Principal:
    return Principal(
        subject=subject,
        name=name,
        email=f"{subject}@example.edu.br",
        role=role,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
    )


@pytest.fixture(autouse=True)
def fresh_database():
    with engine.begin() as connection:
        connection.execute(text("TRUNCATE TABLE sigad_reservations, sigad_members, sigad_laboratories RESTART IDENTITY CASCADE"))
        connection.execute(text("UPDATE sigad_reservation_revision SET value = 0 WHERE id = 1"))
    with SessionForTest.begin() as session:
        session.add_all(
            [
                Member(subject="ana", role="professor", active=True),
                Member(subject="bia", role="coordenador", active=True),
                Member(subject="chefe", role="chefeDepartamento", active=True),
                Member(subject="tec", role="servidorAdministrativo", active=True),
                Laboratory(name="Lab A", operational=True),
                Laboratory(name="Lab B", operational=True),
                Laboratory(name="Lab em manutenção", operational=False),
            ]
        )
    yield
    app.dependency_overrides.clear()


@pytest.fixture
def client():
    def override_db():
        with SessionForTest() as session:
            yield session

    app.dependency_overrides[get_db] = override_db
    app.dependency_overrides[get_principal] = lambda: identity()
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def as_user():
    def set_user(subject="ana", name="Ana", role="professor"):
        app.dependency_overrides[get_principal] = lambda: identity(subject, name, role)
    return set_user
