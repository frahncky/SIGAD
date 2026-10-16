-- RBAC mínimo para banco DEDICADO de homologação.
-- Pré-requisitos: migrações 001 e 002, roles LOGIN criadas pela TI
-- (nenhuma deve ser proprietária das tabelas ou membro de papel privilegiado).
-- Aplicação: psql -v ON_ERROR_STOP=1 -v app_role=... -v backup_role=...
--   -f migrations/003_operational_roles.sql
-- Variáveis psql :"..." fazem escaping de IDENTIFICADOR, não SQL arbitrário.
\if :{?app_role}
\else
\echo 'ERRO: informe -v app_role=<identificador_aprovado>'
\quit 2
\endif
\if :{?backup_role}
\else
\echo 'ERRO: informe -v backup_role=<identificador_aprovado>'
\quit 2
\endif

BEGIN;

-- Nunca conceder privilégios via PUBLIC para os dados desta aplicação.
REVOKE ALL ON TABLE
    public.sigad_members,
    public.sigad_laboratories,
    public.sigad_reservation_revision,
    public.sigad_reservations,
    public.sigad_reservation_audit
FROM PUBLIC;
REVOKE ALL ON SEQUENCE public.sigad_reservation_audit_id_seq FROM PUBLIC;

-- Reexecutável para estas duas roles: começa com o menor conjunto.
REVOKE ALL ON TABLE
    public.sigad_members,
    public.sigad_laboratories,
    public.sigad_reservation_revision,
    public.sigad_reservations,
    public.sigad_reservation_audit
FROM :"app_role", :"backup_role";
REVOKE ALL ON SEQUENCE public.sigad_reservation_audit_id_seq
FROM :"app_role", :"backup_role";
REVOKE CREATE ON SCHEMA public FROM :"app_role", :"backup_role";
GRANT USAGE ON SCHEMA public TO :"app_role", :"backup_role";

-- A API autentica membros, lê laboratórios e a revisão e substitui a agenda.
GRANT SELECT ON TABLE public.sigad_members TO :"app_role";
GRANT SELECT ON TABLE public.sigad_laboratories TO :"app_role";
GRANT SELECT ON TABLE public.sigad_reservation_revision TO :"app_role";
GRANT UPDATE (value) ON TABLE public.sigad_reservation_revision TO :"app_role";
GRANT SELECT, INSERT, DELETE ON TABLE public.sigad_reservations TO :"app_role";

-- Event-sourcing somente inclusão: o ORM usa RETURNING id, recorded_at.
-- Nunca autorizar consulta de actor_subject, owner_subject nem snapshots.
GRANT INSERT ON TABLE public.sigad_reservation_audit TO :"app_role";
GRANT SELECT (id, recorded_at) ON TABLE
    public.sigad_reservation_audit TO :"app_role";

-- Conta de backup SOMENTE LEITURA; pg_dump precisa ler estado da sequência.
GRANT SELECT ON TABLE
    public.sigad_members,
    public.sigad_laboratories,
    public.sigad_reservation_revision,
    public.sigad_reservations,
    public.sigad_reservation_audit
TO :"backup_role";
GRANT SELECT ON SEQUENCE
    public.sigad_reservation_audit_id_seq TO :"backup_role";

COMMIT;
