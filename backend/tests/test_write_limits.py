"""Limites de PUT por sujeito, compartilhados e atômicos no PostgreSQL."""

from concurrent.futures import ThreadPoolExecutor
from threading import Barrier

import pytest
from conftest import SessionForTest, identity
from fastapi import HTTPException
from sqlalchemy import select, text

from sigad_api.write_limits import enforce_write_limit


def _count_for(subject: str) -> int:
    with SessionForTest() as session:
        return session.scalar(
            text(
                "SELECT coalesce(sum(attempts), 0) FROM sigad_write_rate_limits "
                "WHERE actor_subject = :actor"
            ),
            {"actor": subject},
        )


def test_regular_requests_and_noop_do_not_hit_limit(client):
    for _ in range(30):
        response = client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-0", "items": []},
        )
        assert response.status_code == 200, response.text
    assert client.get("/laboratorios/reservas").json() == {
        "revision": "rev-0",
        "items": [],
    }
    assert _count_for("ana") == 30


def test_exhausted_budget_returns_429_with_retry_after_and_no_mutation(client):
    for _ in range(30):
        assert client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-0", "items": []},
        ).status_code == 200

    rejected = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-0", "items": []},
    )
    assert rejected.status_code == 429
    assert rejected.headers["retry-after"] == "60"
    assert "ana" not in rejected.text
    assert _count_for("ana") == 30
    assert client.get("/laboratorios/reservas").json()["revision"] == "rev-0"


def test_budgets_are_independent_for_authenticated_users(client, as_user):
    with SessionForTest() as db:
        enforce_write_limit(db, identity("ana"), max_attempts=1)
        with pytest.raises(HTTPException) as error:
            enforce_write_limit(db, identity("ana"), max_attempts=1)
        assert error.value.status_code == 429

    as_user("bia", "Bia", "coordenador")
    assert client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-0", "items": []},
    ).status_code == 200
    assert _count_for("bia") == 1


def test_fixed_window_resets_at_next_minute():
    with SessionForTest() as db:
        enforce_write_limit(db, identity(), max_attempts=1)
        with pytest.raises(HTTPException):
            enforce_write_limit(db, identity(), max_attempts=1)

    # Simula virada do minuto movendo APENAS o bucket de teste para trás.
    with SessionForTest.begin() as db:
        db.execute(text("UPDATE sigad_write_rate_limits SET minute_bucket=minute_bucket - 1"))
    with SessionForTest() as db:
        enforce_write_limit(db, identity(), max_attempts=1)
    assert _count_for("ana") == 2


def test_two_api_instances_share_atomic_one_attempt_budget():
    barrier = Barrier(2)

    def request():
        with SessionForTest() as db:
            barrier.wait(timeout=10)
            try:
                enforce_write_limit(db, identity(), max_attempts=1)
                return 200
            except HTTPException as error:
                return error.status_code

    with ThreadPoolExecutor(max_workers=2) as workers:
        a = workers.submit(request)
        b = workers.submit(request)
        assert sorted([a.result(timeout=20), b.result(timeout=20)]) == [200, 429]
    assert _count_for("ana") == 1


def test_reservation_conflicts_consume_write_budget(client):
    invalid = {
        "expectedRevision": "rev-999",
        "items": [],
    }
    for _ in range(30):
        assert client.put("/laboratorios/reservas", json=invalid).status_code == 409
    assert client.put("/laboratorios/reservas", json=invalid).status_code == 429
    assert _count_for("ana") == 30


def test_rejected_users_do_not_consume_authenticated_writer_budget(client, as_user):
    as_user("tec", "Técnica", "servidorAdministrativo")
    for _ in range(3):
        assert client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-0", "items": []},
        ).status_code == 403
    assert _count_for("tec") == 0


def test_only_maintenance_can_prune_older_buckets():
    with SessionForTest.begin() as db:
        db.execute(
            text(
                "INSERT INTO sigad_write_rate_limits "
                "(actor_subject, minute_bucket, attempts) "
                "VALUES ('old', 1, 2), ('recent', "
                "floor(extract(epoch FROM statement_timestamp()) / 60)::bigint, 1)"
            )
        )
        db.execute(
            text(
                "DELETE FROM sigad_write_rate_limits WHERE minute_bucket < "
                "floor(extract(epoch FROM statement_timestamp()) / 60)::bigint - 1440"
            )
        )
    with SessionForTest() as db:
        remaining = db.execute(
            text("SELECT actor_subject FROM sigad_write_rate_limits")
        ).scalars().all()
        assert remaining == ["recent"]
