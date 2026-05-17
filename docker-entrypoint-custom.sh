#!/bin/bash
set -e

# Parse POSTGRES_CONFIG and pass settings to postgres via -c flags
# Modes: low, normal, high
# Custom format: "shortname=value,shortname=value,..."
# Example: POSTGRES_CONFIG="low" or POSTGRES_CONFIG="sb=64MB,mc=75"

PG_OPTS=()

add_opt() {
    local option="$1"
    local value="$2"
    PG_OPTS+=( "-c" "${option}=${value}" )
}

generate_config() {
    local config_string="$1"

    IFS=',' read -ra PAIRS <<< "$config_string"
    for pair in "${PAIRS[@]}"; do
        key="${pair%%=*}"
        value="${pair#*=}"

        case "$key" in
            sb)  option="shared_buffers" ;;
            ecs) option="effective_cache_size" ;;
            wm)  option="work_mem" ;;
            mwm) option="maintenance_work_mem" ;;
            mc)  option="max_connections" ;;
            wb)  option="wal_buffers" ;;
            mbc) option="max_wal_size" ;;
            mwc) option="max_worker_processes" ;;
            mpw) option="max_parallel_workers" ;;
            *)   option="$key" ;;
        esac

        add_opt "$option" "$value"
    done

    echo "Generated PostgreSQL runtime options:"
    printf ' %s\n' "${PG_OPTS[@]}"
}

if [ -n "$POSTGRES_CONFIG" ]; then
    case "$POSTGRES_CONFIG" in
        low)
            echo "Applying LOW memory preset..."
            generate_config "sb=32MB,ecs=96MB,wm=2MB,mwm=32MB,mc=50,wb=1MB"
            ;;
        normal)
            echo "Applying NORMAL memory preset..."
            generate_config "sb=128MB,ecs=384MB,wm=4MB,mwm=64MB,mc=100,wb=4MB"
            ;;
        high)
            echo "Applying HIGH performance preset..."
            generate_config "sb=256MB,ecs=768MB,wm=8MB,mwm=128MB,mc=200,wb=8MB"
            ;;
        *)
            echo "Applying custom configuration..."
            generate_config "$POSTGRES_CONFIG"
            ;;
    esac
else
    echo "POSTGRES_CONFIG not set, using PostgreSQL defaults."
fi

if [ "$1" = 'postgres' ] && [ ${#PG_OPTS[@]} -gt 0 ]; then
    set -- postgres "${PG_OPTS[@]}" "${@:2}"
fi

exec docker-entrypoint.sh "$@"
