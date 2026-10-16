-- Migração incremental: NÃO ALTERA nem apaga reservas existentes.
-- Aplicar após 001_initial.sql com backup e janela de mudança autorizada.
BEGIN;

CREATE TABLE IF NOT EXISTS sigad_reservation_audit (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    revision integer NOT NULL CHECK (revision > 0),
    reservation_id varchar(120) NOT NULL,
    actor_subject varchar(255) NOT NULL,
    owner_subject varchar(255) NOT NULL,
    event_type varchar(12) NOT NULL CHECK (event_type IN ('CREATED','UPDATED','REMOVED')),
    slot_before jsonb,
    slot_after jsonb,
    recorded_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
    CONSTRAINT sigad_audit_valid_state CHECK (
        (event_type = 'CREATED' AND slot_before IS NULL AND slot_after IS NOT NULL)
        OR (event_type = 'UPDATED' AND slot_before IS NOT NULL AND slot_after IS NOT NULL)
        OR (event_type = 'REMOVED' AND slot_before IS NOT NULL AND slot_after IS NULL)
    ),
    CONSTRAINT sigad_audit_unique_change UNIQUE (revision, reservation_id)
);

CREATE INDEX IF NOT EXISTS sigad_audit_recorded_at_idx
    ON sigad_reservation_audit (recorded_at);
CREATE INDEX IF NOT EXISTS sigad_audit_actor_idx
    ON sigad_reservation_audit (actor_subject, recorded_at);

-- Por padrão, impedir atualização ou exclusão de eventos já registrados.
-- Administradores/superusuários ainda podem alterar triggers: revogar
-- ownership de aplicação e manter backup externo sob custódia da TI.
CREATE OR REPLACE FUNCTION sigad_reject_audit_changes()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Histórico de auditoria é somente inclusão';
END;
$$;
DROP TRIGGER IF EXISTS sigad_audit_append_only ON sigad_reservation_audit;
CREATE TRIGGER sigad_audit_append_only
BEFORE UPDATE OR DELETE ON sigad_reservation_audit
FOR EACH ROW EXECUTE FUNCTION sigad_reject_audit_changes();

COMMIT;
