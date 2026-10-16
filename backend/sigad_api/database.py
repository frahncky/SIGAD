"""Banco PostgreSQL gerenciado por migrações SQL versionadas."""

from functools import lru_cache

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from .config import database_url


class Base(DeclarativeBase):
    pass


@lru_cache(maxsize=1)
def session_factory() -> sessionmaker[Session]:
    engine = create_engine(database_url(), pool_pre_ping=True, pool_size=5, max_overflow=10)
    return sessionmaker(bind=engine, expire_on_commit=False)


def get_db():
    session = session_factory()()
    try:
        yield session
    finally:
        session.close()
