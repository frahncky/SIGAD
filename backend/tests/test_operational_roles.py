"""Conexões PostgreSQL reais comprovam mínimo privilégio nas roles do SIGAD."""

import os

import pytest
from conftest import identity
from sqlalchemy import create_engine, text
from sqlalchemy.engine import make_url
from sqlalchemy.exc import DBAPIError
from sqlalchemy.orm import Session
from test_reservations import item

from sigad_api.reservations import replace_reservations
from sigad_api.schemas import ReservationWrite


@pytest.fixture
def app_session():
    url = make_url(os.environ["SIGAD_DATABASE_URL"]).set(
        username="sigad_app_ci", password="sigad_app_ci"
    )
    engine = create_engine(url)
    try:
        with Session(engine) as session:
            yield session
    finally:
        engine.dispose()


@pytest.fixture
def backup_session():
    url = make_url(os.environ["SIGAD_DATABASE_URL"]).set(
        username="sigad_backup_ci", password="sigad_backup_ci"
    )
    engine = create_engine(url)
    try:
        with Session(engine) as session:
            yield session
    finally:
        engine.dispose()


def test_runtime_role_can_create_and_audit_without_reading_sensitive_log(app_session):
    saved = replace_reservations(
        app_session,
        identity(),
        ReservationWrite(expectedRevision="rev-0", items=[item()]),
    )
    assert saved == {"revision": "rev-1"}
    with app_session.begin():
        assert app_session.execute(
            text("SELECT count(*) FROM sigad_reservations")
        ).scalar_one() == 1
        # Restrição por coluna: pode consultar id/time usados no RETURNING.
        assert app_session.execute(
            text("SELECT count(id) FROM sigad_reservation_audit")
        ).scalar_one() == 1
    with pytest.raises(DBAPIError), app_session.begin():
        app_session.execute(text("SELECT actor_subject FROM sigad_reservation_audit"))
    app_session.rollback()


@pytest.mark.parametrize(
    "statement",
    [
        "DELETE FROM sigad_reservation_audit",
        "UPDATE sigad_reservation_audit SET actor_subject='troca'",
        "TRUNCATE sigad_reservation_audit",
        "DROP TABLE sigad_reservation_audit",
        "INSERT INTO sigad_members(subject, role, active) VALUES ('evil','professor',true)",
        "UPDATE sigad_laboratories SET operational=true",
        "CREATE TABLE sigad_unapproved_table(id int)",
    ],
)
def test_runtime_role_cannot_manage_history_members_or_schema(app_session, statement):
    with pytest.raises(DBAPIError), app_session.begin():
        app_session.execute(text(statement))
    app_session.rollback()


def test_backup_role_reads_all_data_but_cannot_mutate(backup_session):
    with backup_session.begin():
        for table in (
            "sigad_members",
            "sigad_laboratories",
            "sigad_reservations",
            "sigad_reservation_revision",
            "sigad_reservation_audit",
        ):
            backup_session.execute(text(f"SELECT count(*) FROM {table}")).scalar_one()
    with pytest.raises(DBAPIError), backup_session.begin():
        backup_session.execute(text("UPDATE sigad_laboratories SET operational = false"))
    backup_session.rollback()


def test_app_role_not_owner_and_no_privileged_role_grants(app_session):
    with app_session.begin():
        role = app_session.execute(
            text("SELECT rolsuper, rolcreatedb, rolcreaterole FROM pg_roles WHERE rolname=current_user")
        ).one()
        assert tuple(role) == (False, False, False)
        for table in ("sigad_reservations", "sigad_reservation_audit"):
            owner = app_session.scalar(
                text(
                    "SELECT r.rolname FROM pg_class c JOIN pg_roles r ON r.oid=c.relowner "
                    "WHERE c.oid=to_regclass(:name)"
                ),
                {"name": table},
            )
            assert owner != "sigad_app_ci"
