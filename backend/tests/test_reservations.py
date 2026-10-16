"""Testes de contrato, autorização e concorrência real no PostgreSQL."""

from concurrent.futures import ThreadPoolExecutor
from threading import Barrier

from conftest import SessionForTest, identity
from fastapi import HTTPException
from sqlalchemy import select

from sigad_api.models import Reservation, Revision
from sigad_api.reservations import replace_reservations
from sigad_api.schemas import ReservationWrite


def item(id="r1", professor="Ana", lab="Lab A", turno="matutino", periodo=1):
    return {
        "id": id,
        "professor": professor,
        "laboratorio": lab,
        "ano": 2026,
        "mes": 1,
        "semanaDoMes": 1,
        "diaSemana": "Seg",
        "turno": turno,
        "periodo": periodo,
        "grupoId": id,
    }


def test_read_write_revision_and_noop(client):
    assert client.get("/health").json() == {"status": "ok"}
    response = client.get("/laboratorios/reservas")
    assert response.status_code == 200
    assert response.json() == {"revision": "rev-0", "items": []}

    created = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-0", "items": [item()]},
    )
    assert created.status_code == 200, created.text
    assert created.json()["revision"] == "rev-1"
    data = client.get("/laboratorios/reservas").json()
    assert data["revision"] == "rev-1"
    assert len(data["items"]) == 1

    noop = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-1", "items": data["items"]},
    )
    assert noop.status_code == 200
    assert noop.json()["revision"] == "rev-1"

    outdated = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-0", "items": [item("r2")]},
    )
    assert outdated.status_code == 409
    assert client.get("/laboratorios/reservas").json()["revision"] == "rev-1"


def test_duplicate_slot_rejected_without_side_effects(client):
    response = client.put(
        "/laboratorios/reservas",
        json={
            "expectedRevision": "rev-0",
            "items": [item("r1"), item("r2")],
        },
    )
    assert response.status_code == 409
    assert client.get("/laboratorios/reservas").json() == {
        "revision": "rev-0",
        "items": [],
    }


def test_invalid_slot_and_unprovisioned_or_offline_lab(client):
    invalid = item()
    # Fevereiro/2026 tem somente quatro blocos de sete dias.
    invalid["mes"] = 2
    invalid["semanaDoMes"] = 5
    assert (
        client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-0", "items": [invalid]},
        ).status_code
        == 422
    )
    for lab in ("Lab em manutenção", "Lab inexistente"):
        response = client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-0", "items": [item(lab=lab)]},
        )
        assert response.status_code == 409


def test_only_owner_or_head_can_change_or_remove(client, as_user):
    assert (
        client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-0", "items": [item()]},
        ).status_code
        == 200
    )
    as_user("bia", "Bia", "coordenador")
    data = client.get("/laboratorios/reservas").json()
    changed = {**data["items"][0], "periodo": 2}
    assert (
        client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-1", "items": [changed]},
        ).status_code
        == 403
    )
    assert (
        client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-1", "items": []},
        ).status_code
        == 403
    )
    assert (
        client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-1", "items": [item("r2", professor="Ana")]},
        ).status_code
        == 403
    )
    assert client.get("/laboratorios/reservas").json()["revision"] == "rev-1"

    as_user("chefe", "Chefe", "chefeDepartamento")
    assert (
        client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-1", "items": [changed]},
        ).status_code
        == 200
    )
    assert (
        client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-2", "items": []},
        ).status_code
        == 200
    )


def test_administrative_profile_has_no_reservation_access(client, as_user):
    as_user("tec", "Técnica", "servidorAdministrativo")
    assert client.get("/laboratorios/reservas").status_code == 403
    assert (
        client.put(
            "/laboratorios/reservas",
            json={"expectedRevision": "rev-0", "items": []},
        ).status_code
        == 403
    )


def test_atomic_concurrent_clients_same_revision_one_wins():
    barrier = Barrier(2)

    def save(subject, name, reservation_id):
        # Cada worker tem sua própria conexão/sessão, como dois aparelhos.
        with SessionForTest() as session:
            barrier.wait(timeout=10)
            try:
                response = replace_reservations(
                    session,
                    identity(subject, name),
                    ReservationWrite(
                        expectedRevision="rev-0",
                        items=[item(reservation_id, professor=name)],
                    ),
                )
                return response["revision"]
            except HTTPException as error:
                return error.status_code

    with ThreadPoolExecutor(max_workers=2) as pool:
        a = pool.submit(save, "ana", "Ana", "res-ana")
        b = pool.submit(save, "bia", "Bia", "res-bia")
        results = [a.result(timeout=20), b.result(timeout=20)]

    assert sorted(results, key=str) == sorted(["rev-1", 409], key=str)
    with SessionForTest() as session:
        assert session.scalar(select(Revision.value).where(Revision.id == 1)) == 1
        assert len(session.scalars(select(Reservation)).all()) == 1
