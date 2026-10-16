#!/usr/bin/env bash
# RESTAURAÇÃO APENAS PARA BANCO DESCARTÁVEL DE TESTE previamente vazio.
# NÃO restaura sobre banco com dados nem executa DROP/CREATE DATABASE.
set -euo pipefail
umask 077
die() { printf '%s\n' "Restauração bloqueada: $*" >&2; exit 2; }

[[ "$#" -eq 2 ]] || die "uso: restore_homologacao.sh <arquivo.dump> <arquivo.dump.sha256>"
archive="$1"
manifest="$2"
[[ "${SIGAD_ENVIRONMENT:-}" == "homologacao" ]] || die "ambiente incorreto"
[[ "${SIGAD_RESTORE_CONFIRMATION:-}" == "RESTAURAR_SOMENTE_EM_BANCO_VAZIO" ]] ||
  die "confirmação explícita obrigatória"
[[ "${PGSSLMODE:-}" == "verify-full" ]] || die "exigir PGSSLMODE=verify-full"
[[ -n "${PGSSLROOTCERT:-}" && -r "${PGSSLROOTCERT}" ]] || die "CA ausente"
[[ -n "${PGHOST:-}" && -n "${PGUSER:-}" && -n "${PGDATABASE:-}" ]] ||
  die "informe conexao PostgreSQL"
[[ "${PGDATABASE}" =~ ^sigad_restore_[a-z0-9_]+$ ]] ||
  die "destino deve ser banco isolado sigad_restore_*"
[[ "${SIGAD_RESTORE_TARGET:-}" == "${PGDATABASE}" ]] || die "destino nao confirmado"
[[ -n "${PGPASSFILE:-}" && -r "${PGPASSFILE}" ]] || die "arquivo de senha ausente"
[[ -f "$archive" && ! -L "$archive" && -f "$manifest" && ! -L "$manifest" ]] ||
  die "arquivo ou manifesto invalido"
for cmd in pg_restore psql sha256sum awk; do
  command -v "$cmd" >/dev/null || die "dependencia ausente: $cmd"
done

expected=$(awk 'NR == 1 {print $1}' "$manifest")
[[ "$expected" =~ ^[a-fA-F0-9]{64}$ ]] || die "manifesto SHA-256 invalido"
actual=$(sha256sum "$archive")
[[ "${actual%% *}" == "$expected" ]] || die "integridade do backup rejeitada"
pg_restore --list "$archive" >/dev/null

# Verificação é uma trava para erros operacionais, não barreira contra
# um administrador malicioso. A TI deve isolar o cluster e a rede.
objects=$(psql -X -q -A -t -v ON_ERROR_STOP=1 -c "
 SELECT COUNT(*) FROM pg_class c
 JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='public' AND c.relkind IN ('r','p','v','m','S','f');
")
[[ "$objects" == "0" ]] || die "banco nao vazio; nenhuma alteração realizada"

# Dump custom com esquema e dados; restaura em uma única transação.
# --no-owner/--no-acl evita recriar contas/permissões de origem.
pg_restore --exit-on-error --single-transaction --no-owner --no-acl \
  --dbname="$PGDATABASE" "$archive"
status=$(psql -X -q -A -t -v ON_ERROR_STOP=1 -c "
 SELECT (
    to_regclass('public.sigad_members') IS NOT NULL
    AND to_regclass('public.sigad_reservations') IS NOT NULL
    AND to_regclass('public.sigad_reservation_audit') IS NOT NULL
    AND EXISTS (SELECT 1 FROM public.sigad_reservation_revision WHERE id=1)
 )::integer;
")
[[ "$status" == "1" ]] || die "schema/revisão da restauração inválidos"
printf '%s\n' "Restauração de ensaio concluída no banco isolado: $PGDATABASE"
