# PostgreSQL Any Version

PostgreSQL service for Railway. Choose the PostgreSQL version via the `POSTGRES_VERSION` variable (e.g. `16`, `16.8`, `15`, `14`, `17`).

## Required variable

- **POSTGRES_PASSWORD** – Superuser password. The container will not start without it. On Railway templates, use `${{secret(32)}}` to generate a random password at deploy time.

## Optional variables

- **POSTGRES_VERSION** – Docker image tag (e.g. `16`, `16.8`, `15`, `14`, `17`). Default: `16`.
- **POSTGRES_USER** – Superuser name. Default: `postgres`.
- **POSTGRES_DB** – Database name created on first run. Default: `railway`.
- **POSTGRES_CONFIG** – PostgreSQL configuration preset or custom settings (see below). If not set, PostgreSQL uses its defaults.

## Volume

Mount a volume at **`/var/lib/postgresql/data`** for persistent data. The cluster is stored in **`/var/lib/postgresql/data/pgdata`** (`PGDATA`), not directly on the mount root, so Railway’s volume (`lost+found`) does not block `initdb`.

## Custom PostgreSQL Configuration (POSTGRES_CONFIG)

Use the `POSTGRES_CONFIG` variable to tune PostgreSQL settings without rebuilding the image.

### Presets

Use one of the predefined modes for quick setup:

| Mode | RAM (idle) | Use case |
|------|------------|----------|
| `low` | ~100-200MB | Development, low-traffic apps, saving costs |
| `normal` | ~300-400MB | Standard production workloads |
| `high` | ~500-700MB | High-traffic, performance-critical apps |

If `POSTGRES_CONFIG` is not set, PostgreSQL uses its built-in defaults.

**Example:**
```
POSTGRES_CONFIG=low
```

### Custom Configuration

For fine-tuned control, pass a comma-separated list of `shortname=value` pairs:

```
POSTGRES_CONFIG=sb=64MB,ecs=192MB,mc=75
```

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

You can also use full PostgreSQL option names: `POSTGRES_CONFIG=shared_buffers=64MB,max_connections=50`

### Preset Details

**low** – Minimal memory footprint:
```
sb=32MB, ecs=96MB, wm=2MB, mwm=32MB, mc=50, wb=1MB
```

**normal** – Balanced for typical workloads:
```
sb=128MB, ecs=384MB, wm=4MB, mwm=64MB, mc=100, wb=4MB
```

**high** – Optimized for performance:
```
sb=256MB, ecs=768MB, wm=8MB, mwm=128MB, mc=200, wb=8MB
```

## Changing the PostgreSQL version

Changing `POSTGRES_VERSION` (e.g. from `16` to `17` or to `15`) and redeploying may work without any extra steps—for example, patch updates within the same major version often keep compatibility.

The new version can be **incompatible** with the existing data directory, and the service may then fail to start or accept connections.

**If you run into connection or startup issues after changing the version:** wipe the volume so the data directory matches the chosen version.

1. In the PostgreSQL service on Railway, open the volume and run **Wipe**.
2. Let Railway redeploy (or trigger a redeploy). The new version will initialize on an empty data directory and you should be able to connect again.

Wiping removes all data in the volume. Back up anything you need before wiping.

Versions below 14 are end-of-life and not recommended for new deployments.

## Example (Railway variables)

| Variable             | Example   |
|----------------------|-----------|
| POSTGRES_PASSWORD    | `${{secret(32)}}` |
| POSTGRES_VERSION     | 16        |
| POSTGRES_DB          | railway   |
| POSTGRES_CONFIG      | low       |

## Connecting from other services

Reference these variables from your app (Railway can expose them automatically when linking services):

- `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`
- `DATABASE_URL` (if configured in your project)

Use Railway's TCP Proxy if you need to connect from outside Railway.
