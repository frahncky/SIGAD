"""Transações de agenda serializadas pela linha única de revisão."""

from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from .models import Laboratory, Reservation, Revision
from .schemas import ReservationIn, ReservationWrite
from .security import Principal


def _to_schema(row: Reservation) -> ReservationIn:
    return ReservationIn(
        id=row.id,
        professor=row.professor,
        laboratorio=row.laboratorio,
        ano=row.ano,
        mes=row.mes,
        semanaDoMes=row.semana_do_mes,
        diaSemana=row.dia_semana,
        turno=row.turno,
        periodo=row.periodo,
        disciplina=row.disciplina,
        grupoId=row.grupo_id,
    )


def _assign(row: Reservation, item: ReservationIn) -> None:
    row.professor = item.professor
    row.laboratorio = item.laboratorio
    row.ano = item.ano
    row.mes = item.mes
    row.semana_do_mes = item.semanaDoMes
    row.dia_semana = item.diaSemana
    row.turno = item.turno
    row.periodo = item.periodo
    row.disciplina = item.disciplina
    row.grupo_id = item.grupoId


def _slot(item: ReservationIn) -> tuple:
    return (
        item.laboratorio.casefold(),
        item.ano,
        item.mes,
        item.semanaDoMes,
        item.diaSemana,
        item.turno,
        item.periodo,
    )


def _check_uniqueness(items: list[ReservationIn]) -> None:
    ids = set()
    slots = set()
    for item in items:
        if item.id in ids or _slot(item) in slots:
            raise HTTPException(status_code=409, detail="Reserva ou horário duplicado.")
        ids.add(item.id)
        slots.add(_slot(item))


def list_reservations(db: Session) -> dict:
    # FOR SHARE protege um retrato consistente contra PUT simultâneo.
    with db.begin():
        version = db.execute(
            select(Revision).where(Revision.id == 1).with_for_update(read=True)
        ).scalar_one()
        items = db.execute(select(Reservation).order_by(Reservation.id)).scalars().all()
        return {"revision": f"rev-{version.value}", "items": [_to_schema(row) for row in items]}


def replace_reservations(db: Session, principal: Principal, payload: ReservationWrite) -> dict:
    _check_uniqueness(payload.items)
    try:
        with db.begin():
            # Lock exclusivo: um único writer por vez em TODAS as réplicas API.
            version = db.execute(
                select(Revision).where(Revision.id == 1).with_for_update()
            ).scalar_one()
            if payload.expectedRevision != f"rev-{version.value}":
                raise HTTPException(status_code=409, detail="Agenda desatualizada. Recarregue.")

            old = {row.id: row for row in db.execute(select(Reservation)).scalars().all()}
            incoming = {item.id: item for item in payload.items}
            modified = [
                item
                for item in payload.items
                if item.id not in old or item != _to_schema(old[item.id])
            ]
            removed = [row for key, row in old.items() if key not in incoming]

            # A lista completa pode incluir reservas de terceiros apenas se inalteradas.
            for item in modified:
                previous = old.get(item.id)
                if previous is None:
                    if item.professor != principal.name:
                        raise HTTPException(
                            status_code=403, detail="Reserva deve pertencer ao usuário autenticado."
                        )
                elif (
                    previous.owner_subject != principal.subject
                    and principal.role != "chefeDepartamento"
                ):
                    raise HTTPException(
                        status_code=403, detail="Não pode alterar reserva de terceiros."
                    )
                elif item.professor != previous.professor:
                    raise HTTPException(
                        status_code=403, detail="Responsável não pode ser trocado nesta operação."
                    )

            for row in removed:
                if row.owner_subject != principal.subject and principal.role != "chefeDepartamento":
                    raise HTTPException(
                        status_code=403, detail="Não pode excluir reserva de terceiros."
                    )

            if not modified and not removed:
                return {"revision": f"rev-{version.value}"}

            # Novo horário só pode ser reservado em laboratório provisionado e operante.
            labs = {x.name: x for x in db.execute(select(Laboratory)).scalars().all()}
            for item in modified:
                lab = labs.get(item.laboratorio)
                if lab is None or not lab.operational:
                    raise HTTPException(
                        status_code=409, detail="Laboratório indisponível ou não cadastrado."
                    )

            # DELETE+UPDATE+INSERT preservam as chaves únicas até o commit.
            for row in removed:
                db.delete(row)
            db.flush()
            for item in modified:
                row = old.get(item.id)
                if row is None:
                    row = Reservation(id=item.id, owner_subject=principal.subject)
                    db.add(row)
                _assign(row, item)
            db.flush()
            version.value += 1
            return {"revision": f"rev-{version.value}"}
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="Conflito de horário ou cadastro.") from None
