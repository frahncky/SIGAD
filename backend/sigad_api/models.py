"""Modelos persistidos; owner_subject é sempre definido pelo servidor."""
from sqlalchemy import Boolean, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from .database import Base


class Member(Base):
    __tablename__ = "sigad_members"

    subject: Mapped[str] = mapped_column(String(255), primary_key=True)
    role: Mapped[str] = mapped_column(String(40), nullable=False)
    active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)


class Laboratory(Base):
    __tablename__ = "sigad_laboratories"

    name: Mapped[str] = mapped_column(String(160), primary_key=True)
    operational: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)


class Revision(Base):
    __tablename__ = "sigad_reservation_revision"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    value: Mapped[int] = mapped_column(Integer, nullable=False)


class Reservation(Base):
    __tablename__ = "sigad_reservations"

    id: Mapped[str] = mapped_column(String(120), primary_key=True)
    owner_subject: Mapped[str] = mapped_column(String(255), ForeignKey("sigad_members.subject"), nullable=False)
    professor: Mapped[str] = mapped_column(String(160), nullable=False)
    laboratorio: Mapped[str] = mapped_column(String(160), ForeignKey("sigad_laboratories.name"), nullable=False)
    ano: Mapped[int] = mapped_column(Integer, nullable=False)
    mes: Mapped[int] = mapped_column(Integer, nullable=False)
    semana_do_mes: Mapped[int] = mapped_column(Integer, nullable=False)
    dia_semana: Mapped[str] = mapped_column(String(3), nullable=False)
    turno: Mapped[str] = mapped_column(String(12), nullable=False)
    periodo: Mapped[int] = mapped_column(Integer, nullable=False)
    disciplina: Mapped[str | None] = mapped_column(String(180), nullable=True)
    grupo_id: Mapped[str] = mapped_column(String(120), nullable=False)
