# Deploy and Host

Deploy this repository as a new service on Railway. The service runs PostgreSQL in a container and persists data to a volume. Configure `POSTGRES_PASSWORD` (required) and optionally `POSTGRES_VERSION`, `POSTGRES_USER`, `POSTGRES_DB`, and `POSTGRES_CONFIG` in the service variables.

## About Hosting

This template is hosted as a Docker-based service on Railway. PostgreSQL runs from the official Docker image; the version is chosen via the `POSTGRES_VERSION` build variable. Data is stored in a volume mounted at `/var/lib/postgresql/data`. Use Railway's TCP Proxy if you need to connect from outside Railway.

## Why Deploy

- **Choose your PostgreSQL version** – Set `POSTGRES_VERSION` (e.g. `16`, `15`, `14`, `17`) instead of being locked to a single version.
- **Memory presets** – Use `POSTGRES_CONFIG` to choose between `low`, `normal`, or `high` memory profiles, or define custom settings.
- **Simple setup** – Set `POSTGRES_PASSWORD` and optionally the database name; no extra config required.
- **Persistent data** – Attach a volume at `/var/lib/postgresql/data` so data survives redeploys (data lives in the `pgdata` subdirectory).
- **General-purpose database** – Official PostgreSQL image with UTF-8 defaults, suitable for most applications.

## Memory Presets

Control PostgreSQL memory usage via the `POSTGRES_CONFIG` variable:

| Preset | RAM (idle) | Use case |
|--------|------------|----------|
| `low` | ~100-200MB | Development, low-traffic apps, cost savings |
| `normal` | ~300-400MB | Standard production workloads |
| `high` | ~500-700MB | High-traffic, performance-critical apps |

If `POSTGRES_CONFIG` is not set, PostgreSQL uses its built-in defaults.

### Shortname Reference

| Shortname | PostgreSQL Option | Description |
|-----------|-------------------|-------------|
| `sb` | shared_buffers | Main shared memory cache |
| `ecs` | effective_cache_size | Planner estimate of OS cache available |
| `wm` | work_mem | Memory per sort/hash operation |
| `mwm` | maintenance_work_mem | Memory for VACUUM, CREATE INDEX, etc. |
| `mc` | max_connections | Maximum simultaneous connections |
| `wb` | wal_buffers | WAL buffer size |
| `mbc` | max_wal_size | Maximum WAL size before checkpoint |
| `mwc` | max_worker_processes | Background worker processes |
| `mpw` | max_parallel_workers | Maximum parallel workers |

You can also pass custom settings: `POSTGRES_CONFIG=sb=64MB,mc=75,mwm=48MB`
or use full PostgreSQL option names: `POSTGRES_CONFIG=shared_buffers=64MB,max_connections=50`

## Common Use Cases

- Backend database for web apps (Node, Python, Ruby, Go, etc.)
- Development or staging PostgreSQL when you need a specific major version (e.g. 15 or 16)
- Low-memory PostgreSQL for hobby projects or cost-sensitive deployments
- Any project that needs PostgreSQL with a configurable version on Railway

## Dependencies for

This template provides a PostgreSQL server. Your application (or other services) depend on it for database storage.

### Deployment Dependencies

- **POSTGRES_PASSWORD** (required) – Superuser password for PostgreSQL. Use `${{secret(32)}}` in the template so Railway generates a random password on first deploy; the container will not start without it.
- **Volume** – Add a volume mounted at `/var/lib/postgresql/data` for persistent data. Without it, data is lost on redeploy. Do not point `PGDATA` at the mount root; this image sets `PGDATA=/var/lib/postgresql/data/pgdata` for Railway compatibility.
- **POSTGRES_VERSION** (optional) – Docker image tag (e.g. `16`, `15`, `14`, `17`). Default: `16`.
- **POSTGRES_USER** (optional) – Superuser name. Default: `postgres`.
- **POSTGRES_DB** (optional) – Database name created on first run. Default: `railway`.
- **POSTGRES_CONFIG** (optional) – Memory preset (`low`, `normal`, `high`) or custom config. If not set, PostgreSQL uses its defaults.
