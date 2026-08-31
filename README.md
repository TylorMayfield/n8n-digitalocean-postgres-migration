# n8n to DigitalOcean Managed PostgreSQL migration checks

This repository contains deliberately small, non-destructive checks for a planned migration of a self-hosted n8n instance from SQLite to DigitalOcean Managed PostgreSQL.

Read the complete runbook before using these files: [Move n8n from SQLite to PostgreSQL on DigitalOcean Without Losing Credentials](https://www.tylor.nz/content/migrate-n8n-sqlite-to-postgresql).

## What this repository does

- Checks that the local n8n data directory and a named recovery archive exist before a change window.
- Checks a PostgreSQL connection and records basic database facts after cutover.
- Provides a local PostgreSQL container for testing connection details.

It does not export or import n8n workflows or credentials. Those actions depend on the n8n version in use and can damage a production instance when guessed. Follow the current n8n documentation and test the exact procedure in isolation first.

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

## Local test database

Use the container only to test your client and application configuration. It is not a replica of a DigitalOcean managed cluster.

```sh
docker compose -f docker-compose.test.yml up -d
psql "postgresql://n8n_app:replace-local-password@127.0.0.1:54329/n8n" -c 'select current_database(), current_user;'
docker compose -f docker-compose.test.yml down -v
```

## Disclosure

I am a DigitalOcean affiliate. This repository contains a DigitalOcean affiliate link. If you use it to create an account or service, I may earn a commission at no extra cost to you.

[Create a managed PostgreSQL database on DigitalOcean](https://www.awin1.com/cread.php?s=4757508&v=123996&q=601070&r=3054551)

## License

MIT. See [LICENSE](LICENSE).
