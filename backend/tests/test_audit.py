"""Auditoria transacional no PostgreSQL, sem depender de infraestrutura IFMA."""

import pytest
from sqlalchemy import select, text
from sqlalchemy.exc import DBAPIError

from conftest import SessionForTest
from sigad_api.models import ReservationAudit, Revision
from test_reservations import item


def _audit():
    with SessionForTest() as session:
        return session.scalars(
            select(ReservationAudit).order_by(ReservationAudit.id)
        ).all()


def test_create_modify_remove_and_noop_audit(client):
    initial = item()
    response = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-0", "items": [initial]},
    )
    assert response.status_code == 200, response.text
    assert len(_audit()) == 1

    # Salvar lista idêntica não altera a revisão e não cria auditoria.
    same = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-1", "items": [initial]},
    )
    assert same.status_code == 200
    assert same.json()["revision"] == "rev-1"
    assert len(_audit()) == 1

    updated = {**initial, "periodo": 2, "disciplina": "Circuitos"}
    response = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-1", "items": [updated]},
    )
    assert response.status_code == 200, response.text
    assert response.json()["revision"] == "rev-2"

    response = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-2", "items": []},
    )
    assert response.status_code == 200, response.text

    records = _audit()
    assert [r.event_type for r in records] == ["CREATED", "UPDATED", "REMOVED"]
    assert [r.revision for r in records] == [1, 2, 3]
    assert [r.actor_subject for r in records] == ["ana", "ana", "ana"]
    assert [r.owner_subject for r in records] == ["ana", "ana", "ana"]
    assert all(r.reservation_id == "r1" for r in records)
    assert all(r.recorded_at is not None for r in records)
    assert records[0].slot_before is None
    assert records[0].slot_after["periodo"] == 1
    assert records[1].slot_before["periodo"] == 1
    assert records[1].slot_after["periodo"] == 2
    assert records[2].slot_before["periodo"] == 2
    assert records[2].slot_after is None
    # O histórico não duplica nomes, emails ou disciplinas.
    assert "Circuitos" not in str(records[1].slot_after)
    assert "Ana" not in str(records[1].slot_after)


def test_conflict_and_unauthorized_mutation_leave_audit_unchanged(client, as_user):
    initial = item()
    assert client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-0", "items": [initial]},
    ).status_code == 200

    stale = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-0", "items": [initial]},
    )
    assert stale.status_code == 409

    invalid_slot = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-1", "items": [initial, item("r2")]},
    )
    assert invalid_slot.status_code == 409

    as_user("bia", "Bia", "coordenador")
    forbidden = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-1", "items": []},
    )
    assert forbidden.status_code == 403

    assert len(_audit()) == 1
    with SessionForTest() as session:
        assert session.scalar(select(Revision.value).where(Revision.id == 1)) == 1


def test_head_action_has_real_actor_and_preserves_original_owner(client, as_user):
    original = item()
    assert client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-0", "items": [original]},
    ).status_code == 200
    as_user("chefe", "Chefe", "chefeDepartamento")
    changed = {**original, "periodo": 3}
    response = client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-1", "items": [changed]},
    )
    assert response.status_code == 200
    last = _audit()[-1]
    assert last.actor_subject == "chefe"
    assert last.owner_subject == "ana"
    assert last.event_type == "UPDATED"
    assert last.revision == 2


def test_audit_entries_cannot_be_updated_or_deleted(client):
    assert client.put(
        "/laboratorios/reservas",
        json={"expectedRevision": "rev-0", "items": [item()]},
    ).status_code == 200
    with SessionForTest() as session:
        with pytest.raises(DBAPIError):
            session.execute(
                text("UPDATE sigad_reservation_audit SET event_type='REMOVED' WHERE id=1")
            )
        session.rollback()
    with SessionForTest() as session:
        with pytest.raises(DBAPIError):
            session.execute(text("DELETE FROM sigad_reservation_audit WHERE id=1"))
        session.rollback()
    assert len(_audit()) == 1
