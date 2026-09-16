# EventNest — One-Command Docker Stack

Runs the full EventNest application (Postgres + Redis + API + UI) with a single command.

> The API and UI source code lives in its own repositories and is **intentionally not tracked here**.
> Clone both into this folder before starting the stack.

## Prerequisites

- Docker Desktop (running)
- Git

## Quickstart

```powershell
git clone https://github.com/Nikhilesh515/EventNest-NodeRec.git
cd EventNest-NodeRec

# Source repos (required — this repo only contains the compose stack)
git clone -b feat/Enhancements/LocalStorageFix https://github.com/Nikhilesh515/EventNest-Node.git EventNest-Node
git clone -b feat/Enhancements/LocalStorageFix https://github.com/Nikhilesh515/EventNest-UI.git   EventNest-UI

docker compose up --build
```

First run takes a few minutes (image pulls + two `npm ci` builds). Subsequent runs take seconds.

## Services

| Service  | URL                   | Notes                                                 |
|----------|-----------------------|-------------------------------------------------------|
| UI       | http://localhost:5173 | nginx-served SPA, reverse-proxies `/api` to the API   |
| API      | http://localhost:5000 | `/health` for status; DB is migrated + seeded on boot |
| Postgres | internal only         | port 5432 inside the compose network, not published   |
| Redis    | internal only         | port 6379 inside the compose network, not published   |

Seeded admin: `admin@eventnest.io` / `Admin@123`

## Common commands

```powershell
docker compose up --build -d                                  # start in background
docker compose logs -f migrate                                # watch migrations + seeds
docker compose ps                                             # status
docker compose down                                           # stop, keep data
docker compose down -v                                        # stop, wipe the database
docker compose exec postgres psql -U postgres -d eventnest    # DB shell
```

## Updating the API / UI

The source repos are ordinary clones, so update them like any other repo:

```powershell
git -C EventNest-Node pull
git -C EventNest-UI pull
docker compose up --build
```

Plain `docker compose up` reuses existing images — pass `--build` after pulling.

## Notes

- Migrations and seeds run automatically via the one-shot `migrate` service (`docker/migrate.sh`).
  Both are idempotent, so re-running the stack is safe.
- Tested against EventNest-Node `39d3c68` and EventNest-UI `b61b290`
  (both on branch `feat/Enhancements/LocalStorageFix`).
- If a fresh clone of either source repo looks nearly empty, you are on the wrong branch —
  the code lives on `feat/Enhancements/LocalStorageFix`, not `master`.
- Optional overrides go in a `.env` file next to `docker-compose.yml`
  (`JWT_SECRET`, `CORS_ORIGINS`, `COOKIE_SECURE`, `LOG_LEVEL`); the built-in defaults work as-is.
