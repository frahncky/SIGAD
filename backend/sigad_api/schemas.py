"""Contratos de reserva compatíveis com o aplicativo Flutter."""
from datetime import date
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


Day = Literal["Seg", "Ter", "Qua", "Qui", "Sex"]
Shift = Literal["matutino", "vespertino", "noturno"]
Role = Literal["professor", "coordenador", "servidorAdministrativo", "chefeDepartamento"]


class ReservationIn(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    id: str = Field(min_length=1, max_length=120)
    professor: str = Field(min_length=1, max_length=160)
    laboratorio: str = Field(min_length=1, max_length=160)
    ano: int = Field(ge=2020, le=2100)
    mes: int = Field(ge=1, le=12)
    semanaDoMes: int = Field(ge=1, le=5)
    diaSemana: Day
    turno: Shift
    periodo: int = Field(ge=1, le=6)
    disciplina: str | None = Field(default=None, max_length=180)
    grupoId: str = Field(min_length=1, max_length=120)

    @field_validator("professor", "laboratorio", "id", "grupoId")
    @classmethod
    def not_blank(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Campo obrigatório.")
        return value

    @model_validator(mode="after")
    def valid_slot(self):
        if self.turno == "noturno" and self.periodo > 5:
            raise ValueError("Período inválido para o turno noturno.")
        first = (self.semanaDoMes - 1) * 7 + 1
        valid = False
        weekdays = ("Seg", "Ter", "Qua", "Qui", "Sex")
        for day in range(first, first + 7):
            try:
                d = date(self.ano, self.mes, day)
            except ValueError:
                break
            if d.weekday() < 5 and weekdays[d.weekday()] == self.diaSemana:
                valid = True
                break
        if not valid:
            raise ValueError("Data e dia da semana inconsistentes.")
        return self


class ReservationWrite(BaseModel):
    model_config = ConfigDict(extra="forbid")
    expectedRevision: str = Field(pattern=r"^rev-[0-9]+$", max_length=40)
    items: list[ReservationIn] = Field(max_length=3000)


class ReservationRead(BaseModel):
    revision: str
    items: list[ReservationIn]


class RevisionRead(BaseModel):
    revision: str


class MeRead(BaseModel):
    id: str
    name: str
    email: str
    role: Role
    expiresAt: str
