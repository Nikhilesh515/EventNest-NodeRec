#!/bin/sh
set -e

# Fresh-DB ordering fix: 20260916000001_create_role_permissions.ts inserts rows
# keyed by role ids read from the roles table, but roles only exist after seeds
# run. Hold those migrations back, migrate + seed, then apply them last.
LATE_MIGRATIONS="20260916000001_create_role_permissions.ts
20260917000001_add_foreign_keys.ts
20260918000001_drop_refresh_token_legacy_columns.ts"

# Self-heal: restore files left hidden by a previously interrupted run.
for m in $LATE_MIGRATIONS; do
  if [ -f "/tmp/late-migrations/$m" ] && [ ! -f "migrations/$m" ]; then
    mv "/tmp/late-migrations/$m" migrations/
  fi
done

if node -e "const {Client}=require('pg');const c=new Client({connectionString:process.env.DATABASE_URL});c.connect().then(()=>c.query(\"select 1 from knex_migrations where name='20260918000001_drop_refresh_token_legacy_columns.ts'\")).then(r=>{c.end();process.exit(r.rowCount>0?0:1);}).catch(()=>process.exit(1));"; then
  echo "Database already migrated; running migrate + seed (idempotent)."
  npm run db:migrate
  npm run db:seed
  exit 0
fi

mkdir -p /tmp/late-migrations
for m in $LATE_MIGRATIONS; do
  if [ -f "migrations/$m" ]; then
    mv "migrations/$m" /tmp/late-migrations/
  fi
done

npm run db:migrate
npm run db:seed

for m in $LATE_MIGRATIONS; do
  if [ -f "/tmp/late-migrations/$m" ]; then
    mv "/tmp/late-migrations/$m" migrations/
  fi
done

npm run db:migrate
