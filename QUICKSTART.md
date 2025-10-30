# Quick Start Guide

## Simple Deployment

### 1. Prerequisites

- Docker and Docker Compose installed
- Squid access logs available

### 2. Download and Start

```bash
# Create project directory
mkdir squid-analytics
cd squid-analytics

# Download docker-compose.yml
curl -o docker-compose.yml https://raw.githubusercontent.com/ajeris/squid-monitoring/main/docker-compose.yml

# Create logs directory
mkdir -p logs

# Copy your Squid logs to ./logs/ directory
cp /var/log/squid/access.log* ./logs/

# Or edit docker-compose.yml to mount your logs directly:
# - /path/to/your/squid/logs:/var/log/squid:ro

# Start container
docker-compose up -d
```

### 3. Access Web Interface

- **Main Page**: http://localhost:8080/
- **SqStat Dashboard**: http://localhost:8080/sqstat/
- **SquidAnalyzer Reports**: http://localhost:8080/squidanalyzer/

## What Happens Automatically

??? **On First Run:**
- Container creates default configuration directories:
  - `./squidanalyzer/` - SquidAnalyzer config files
  - `./apache-webdata/` - Web content and SqStat files
- All files are ready to edit on your host system

??? **Configuration:**
- Edit `./squidanalyzer/squidanalyzer.conf` for SquidAnalyzer settings
- Edit `./apache-webdata/sqstat/config.inc.php` for SqStat settings
- Restart container to apply SquidAnalyzer changes
- SqStat changes apply immediately

??? **Reset to Defaults:**
```bash
docker-compose down
rm -rf ./squidanalyzer ./apache-webdata
docker-compose up -d
```

## Troubleshooting

**No data in reports?**
- Verify Squid logs exist in `./logs/` directory
- Check log format matches expectations
- View container logs: `docker-compose logs`

**Can't access web interface?**
- Check port 8080 is not blocked
- Change port if needed: `"8081:80"` in docker-compose.yml
- Verify container is running: `docker-compose ps`

## Directory Structure After First Run

```
squid-analytics/
????????? docker-compose.yml
????????? logs/                     # Your Squid logs
???   ????????? access.log
????????? squidanalyzer/           # Auto-created config
???   ????????? squidanalyzer.conf   # Main configuration
???   ????????? excluded             # URL exclusions
???   ????????? ...
????????? apache-webdata/          # Auto-created web content
    ????????? index.html           # Main landing page
    ????????? sqstat/              # Real-time dashboard
    ???   ????????? config.inc.php   # SqStat configuration
    ???   ????????? ...
    ????????? squidanalyzer/       # Generated reports
```

That's it! Your Squid log analysis system is ready to use.

## Advanced Setup (Optional)

### Automated Report Generation

For regular report updates, setup cron on the host system:

```bash
# 1. Install SquidAnalyzer on host (outside container)
wget https://github.com/darold/squidanalyzer/archive/master.zip
unzip master.zip && cd squidanalyzer-master/

## Report Generation

### Automated Reports (Recommended)

Setup cron for daily report generation:

```bash
crontab -e
# Add: 00 02 * * * docker exec -t squid-analytics squid-analyzer > /dev/null 2>&1
```

### Manual Reports

```bash
# Generate reports manually
docker exec -t squid-analytics squid-analyzer
```

## Configuration

Edit configuration files after first run:

### SqStat Real-time Dashboard

SqStat connects to Squid servers via cachemgr interface:

1. **Configure Squid servers** in `./apache-webdata/sqstat/config.inc.php`
2. **Update network settings** in docker-compose.yml (change eth0 to your interface)
3. **Configure Squid cachemgr** access for IP 192.168.10.22


- `./squidanalyzer/squidanalyzer.conf` - Main settings
- `./squidanalyzer/network-aliases` - Network name mappings
- `./apache-webdata/sqstat/config.inc.php` - SqStat dashboard

See [README.md](README.md#squidanalyzer-configuration) for detailed configuration guide.
