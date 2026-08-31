#!/usr/bin/env bash
set -euo pipefail

config_file=${1:-migration.env}
[[ -f "$config_file" ]] || { echo "Missing $config_file. Copy migration.env.example first." >&2; exit 1; }
command -v psql >/dev/null || { echo "psql is required." >&2; exit 1; }

set -a
. "$config_file"
set +a

[[ -n "${POSTGRES_URL:-}" ]] || { echo "POSTGRES_URL is required in $config_file." >&2; exit 1; }
[[ "$POSTGRES_URL" != *"REPLACE_WITH_PASSWORD"* ]] || { echo "Set a real POSTGRES_URL in $config_file." >&2; exit 1; }

psql "$POSTGRES_URL" -v ON_ERROR_STOP=1 -c \
  "select current_database() as database, current_user as database_user, now() as checked_at;"
printf 'Connection check passed. Verify n8n workflows and credential decryption separately.\n'
