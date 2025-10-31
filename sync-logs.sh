#!/bin/bash
# Script to sync Squid access logs from multiple Docker hosts
# Designed for non-interactive use (e.g., in cron)

set -euo pipefail

# === Configuration ===
ANALYTICS_HOST=$(hostname -I | awk '{print $1}')
LOG_BASE_DIR="./logs"

# Squid servers configuration
declare -A SQUID_HOSTS=(
    ["squid1"]="192.168.10.39:22:/export/hron-2/appdata/squid-1/logs/"
    ["squid2"]="192.168.12.13:22:/root/appdata/squid_docker/logs/"
    # ["squid3"]="192.168.20.10:22:/var/log/squid/"
)

echo "Starting Squid access.log synchronization..."

# Create log directories if not exist
mkdir -p "$LOG_BASE_DIR"

# === Sync loop ===
for host in "${!SQUID_HOSTS[@]}"; do
    config="${SQUID_HOSTS[$host]}"
    IFS=':' read -r ip port path <<< "$config"
    target_dir="${LOG_BASE_DIR}/${host}"

    echo "Syncing access.log from $host ($ip)..."
    mkdir -p "$target_dir"

    # Sync only access.log file, skip errors quietly
    rsync -avz --timeout=30 \
        -e "ssh -p $port -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes" \
        "root@$ip:${path}access.log" \
        "$target_dir/" >/dev/null 2>&1 || {
        echo "Failed to sync from $host ($ip)"
        continue
    }

    echo "$host sync completed"
done

echo "Log synchronization finished."
echo "Logs stored in: $LOG_BASE_DIR/"

# === Optional: Run SquidAnalyzer automatically ===
# Uncomment if you want to run it automatically after sync
# echo "Running SquidAnalyzer..."
docker exec -t squid-analytics squid-analyzer || echo "SquidAnalyzer failed"
