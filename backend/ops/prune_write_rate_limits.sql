-- Executar por operador autorizado em tarefa periódica (por exemplo, a cada hora).
-- Retém no máximo os buckets dos últimos 24h; sem dados de disciplinas.
-- A API não recebe privilégio de DELETE nesta tabela.
-- Revisar período e base legal com equipe LGPD antes de implantação.
DELETE FROM public.sigad_write_rate_limits
WHERE minute_bucket <
    floor(extract(epoch FROM statement_timestamp()) / 60)::bigint - 1440;
