#!/usr/bin/env bash
set -euo pipefail

config_file=${1:-migration.env}
[[ -f "$config_file" ]] || { echo "Missing $config_file. Copy migration.env.example first." >&2; exit 1; }

set -a
. "$config_file"
set +a

for name in N8N_DATA_DIR BACKUP_FILE POSTGRES_URL; do
  [[ -n "${!name:-}" ]] || { echo "$name is required in $config_file." >&2; exit 1; }
done

[[ -d "$N8N_DATA_DIR" ]] || { echo "N8N_DATA_DIR does not exist: $N8N_DATA_DIR" >&2; exit 1; }
[[ -s "$BACKUP_FILE" ]] || { echo "BACKUP_FILE is missing or empty: $BACKUP_FILE" >&2; exit 1; }
[[ "$POSTGRES_URL" != *"REPLACE_WITH_PASSWORD"* ]] || { echo "Set a real POSTGRES_URL in $config_file." >&2; exit 1; }

printf 'Preflight passed. n8n data directory and recovery archive exist.\n'
printf 'This script did not modify n8n or PostgreSQL.\n'
