-- Limitação atômica de PUT por sujeito autenticado e minuto UTC.
-- Aplicar DEPOIS de 001/002/003; a TI deve provisionar as duas roles.
-- Exigir -v app_role=NOME -v backup_role=NOME (identificadores SQL).
\if :{?app_role}
\else
\echo 'ERRO: informar -v app_role'
\quit 2
\endif
\if :{?backup_role}
\else
\echo 'ERRO: informar -v backup_role'
\quit 2
\endif

BEGIN;
CREATE TABLE IF NOT EXISTS public.sigad_write_rate_limits (
    actor_subject varchar(255) NOT NULL,
    minute_bucket bigint NOT NULL CHECK (minute_bucket >= 0),
    attempts integer NOT NULL CHECK (attempts >= 1),
    PRIMARY KEY (actor_subject, minute_bucket)
);
CREATE INDEX IF NOT EXISTS sigad_write_rate_limits_bucket_idx
    ON public.sigad_write_rate_limits (minute_bucket);

REVOKE ALL ON TABLE public.sigad_write_rate_limits FROM PUBLIC;
REVOKE ALL ON TABLE public.sigad_write_rate_limits FROM :"app_role", :"backup_role";
GRANT SELECT, INSERT, UPDATE (attempts)
    ON TABLE public.sigad_write_rate_limits TO :"app_role";
GRANT SELECT ON TABLE public.sigad_write_rate_limits TO :"backup_role";
COMMIT;
