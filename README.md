# n8n to DigitalOcean Managed PostgreSQL migration checks

This repository contains deliberately small, non-destructive checks for a planned migration of a self-hosted n8n instance from SQLite to DigitalOcean Managed PostgreSQL.

## Read the guide

[Migrate n8n from SQLite to PostgreSQL on DigitalOcean with a tested cutover](https://www.tylor.nz/content/migrate-n8n-sqlite-to-postgresql)

## Disclosure

This README includes a DigitalOcean affiliate link. If you use it, I may earn a commission at no additional cost to you.

[Create a managed PostgreSQL database on DigitalOcean](https://www.awin1.com/cread.php?s=4757508&v=123996&q=601070&r=3054551)

## What this repository does

- Checks that the local n8n data directory and a named recovery archive exist before a change window.
- Checks a PostgreSQL connection and records basic database facts after cutover.
- Provides a local PostgreSQL container for testing connection details.
- Includes a PostgreSQL environment-variable template and a Compose override that mounts a directory for the n8n entity export.

The scripts do not export or import n8n workflows or credentials. The Compose override supports n8n's own `export:entities` and `import:entities` commands, which the article walks through for this migration. Test the exact procedure in isolation first.

## Use it

```sh
git clone https://github.com/TylorMayfield/n8n-digitalocean-postgres-migration.git
cd n8n-digitalocean-postgres-migration
cp migration.env.example migration.env
# Edit migration.env with local paths and the protected PostgreSQL URL.
./scripts/preflight.sh migration.env
./scripts/verify-postgres.sh migration.env
```

The scripts read the connection URL from `migration.env`. Do not commit that file. Use the connection details from the DigitalOcean control panel and restrict the cluster's trusted sources to the n8n server and temporary administrator access.

## Files to merge into your deployment

`n8n-postgres.env.example` lists the PostgreSQL values n8n reads. Merge them into the existing `.env` file next to your Compose file. Do not replace that file. It also contains the existing n8n hostname, webhook, and encryption-key settings. Preserve `N8N_ENCRYPTION_KEY` exactly as it is.

`compose.migration.yml` mounts `./migration-entities` into the n8n container at `/migration`. Use it with your existing Compose file while you run `n8n export:entities` from SQLite, then `n8n import:entities` into a new, empty PostgreSQL database. The article has the exact sequence and safety checks.

## Local test database

Use the container only to test your client and application configuration. It is not a replica of a DigitalOcean managed cluster.

```sh
docker compose -f docker-compose.test.yml up -d
psql "postgresql://n8n_app:replace-local-password@127.0.0.1:54329/n8n" -c 'select current_database(), current_user;'
docker compose -f docker-compose.test.yml down -v
```

## License

MIT. See [LICENSE](LICENSE).
