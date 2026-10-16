-- Executar uma vez em banco PostgreSQL dedicado (revisão versionada).
BEGIN;

CREATE TABLE IF NOT EXISTS sigad_members (
    subject varchar(255) PRIMARY KEY,
    role varchar(40) NOT NULL CHECK (role IN ('professor', 'coordenador', 'servidorAdministrativo', 'chefeDepartamento')),
    active boolean NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS sigad_laboratories (
    name varchar(160) PRIMARY KEY,
    operational boolean NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS sigad_reservation_revision (
    id integer PRIMARY KEY CHECK (id = 1),
    value integer NOT NULL CHECK (value >= 0)
);
INSERT INTO sigad_reservation_revision (id, value) VALUES (1, 0) ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS sigad_reservations (
    id varchar(120) PRIMARY KEY,
    owner_subject varchar(255) NOT NULL REFERENCES sigad_members(subject),
    professor varchar(160) NOT NULL,
    laboratorio varchar(160) NOT NULL REFERENCES sigad_laboratories(name),
    ano integer NOT NULL CHECK (ano BETWEEN 2020 AND 2100),
    mes integer NOT NULL CHECK (mes BETWEEN 1 AND 12),
    semana_do_mes integer NOT NULL CHECK (semana_do_mes BETWEEN 1 AND 5),
    dia_semana varchar(3) NOT NULL CHECK (dia_semana IN ('Seg','Ter','Qua','Qui','Sex')),
    turno varchar(12) NOT NULL CHECK (turno IN ('matutino','vespertino','noturno')),
    periodo integer NOT NULL CHECK (periodo BETWEEN 1 AND 6),
    disciplina varchar(180),
    grupo_id varchar(120) NOT NULL
);

-- Segundo nível de proteção: exclusão mútua no próprio PostgreSQL.
CREATE UNIQUE INDEX IF NOT EXISTS sigad_reservations_unique_slot
    ON sigad_reservations (lower(laboratorio), ano, mes, semana_do_mes, dia_semana, turno, periodo);

COMMIT;
