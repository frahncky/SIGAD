#!/usr/bin/env bash
# Backup lógico local do banco de homologação, via papel dedicado de leitura.
# Execução manual pela TI em host aprovado. Nada é enviado automaticamente.
set -euo pipefail
umask 077

die() { printf '%s\n' "Backup bloqueado: $*" >&2; exit 2; }

[[ "${SIGAD_ENVIRONMENT:-}" == "homologacao" ]] || die "ambiente deve ser homologacao"
[[ "${PGSSLMODE:-}" == "verify-full" ]] || die "exigir PGSSLMODE=verify-full"
[[ -n "${PGSSLROOTCERT:-}" && -r "${PGSSLROOTCERT}" ]] || die "CA do banco ausente"
[[ -n "${PGHOST:-}" && -n "${PGUSER:-}" && -n "${PGDATABASE:-}" ]] ||
  die "informe PGHOST, PGUSER e PGDATABASE"
[[ "${PGDATABASE}" =~ ^[a-z][a-z0-9_]*$ ]] || die "nome do banco invalido"
[[ -n "${PGPASSFILE:-}" && -r "${PGPASSFILE}" ]] || die "arquivo de senha ausente"
[[ -n "${SIGAD_BACKUP_DIRECTORY:-}" && -d "${SIGAD_BACKUP_DIRECTORY}" ]] ||
  die "diretorio de backup preexistente obrigatorio"
[[ ! -L "${SIGAD_BACKUP_DIRECTORY}" ]] || die "diretorio simbolico nao permitido"

for cmd in pg_dump pg_restore sha256sum mktemp date mv; do
  command -v "$cmd" >/dev/null || die "dependencia ausente: $cmd"
done

timestamp=$(date -u +%Y%m%dT%H%M%SZ)
dir="${SIGAD_BACKUP_DIRECTORY%/}"
destination="$dir/sigad_${PGDATABASE}_${timestamp}.dump"
[[ ! -e "$destination" && ! -e "$destination.sha256" ]] ||
  die "backup para este minuto ja existe"
temporary=$(mktemp "$dir/.sigad-backup.XXXXXXXX")
checksum_temp=$(mktemp "$dir/.sigad-checksum.XXXXXXXX")
cleanup() { rm -f -- "$temporary" "$checksum_temp"; }
trap cleanup EXIT

pg_dump --format=custom --no-password --file="$temporary"
pg_restore --list "$temporary" >/dev/null
hash=$(sha256sum "$temporary")
printf '%s  %s\n' "${hash%% *}" "$(basename "$destination")" > "$checksum_temp"
chmod 600 "$temporary" "$checksum_temp"
mv -n -- "$temporary" "$destination"
mv -n -- "$checksum_temp" "$destination.sha256"
printf '%s\n' "Backup local criado e hash SHA-256 gravado em: $destination"
# O hash detecta corrupção acidental, não substitui assinatura/autenticidade.
