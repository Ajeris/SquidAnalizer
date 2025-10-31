# 🦑 Squid Log Analytics Container

[![Docker Build](https://img.shields.io/badge/docker%20build-blue.svg)](https://hub.docker.com/r/ajeris/squid-analytics)
[![GitHub](https://img.shields.io/github/last-commit/ajeris/squid-analytics/main?label=last%20update&color=blue)](https://github.com/ajeris/squid-analytics)
[![Debian](https://img.shields.io/badge/base-Debian%2012--slim-orange)](https://www.debian.org/)
[![License](https://img.shields.io/badge/license-GPLv3-green)](#license)

An optimized Docker image providing **Squid log analytics (SquidAnalyzer)** and **real-time monitoring (SqStat)** on **Debian 12-slim** with **Apache2**.

**Badges:** Debian 12-slim • SquidAnalyzer 6.x • SqStat • Apache2 • Self-contained

---

## 🧭 Overview

This container is designed to be a companion to an existing **Squid** deployment. It:

- Parses Squid access logs and generates daily/weekly/monthly HTML reports (**SquidAnalyzer**)
- Shows real-time connections, users, bandwidth, and targets (**SqStat**)
- Auto-initializes default configs and web assets on first run

---

## ✨ Features

- SquidAnalyzer reports (tables, charts, localization)
- SqStat real-time dashboard
- Apache2 web UI — zero-config on first start
- Volume-friendly: configs and web data persist on host
- Works with bridge/macvlan or alongside a Squid container

---

## 🚀 Quick Start

1. Ensure you have **Squid access logs** available on the host (bind-mounted to `./logs`).

2. Example `docker-compose.yml` (macvlan example with a static IP for the container):

```yaml
services:
  squid-analytics:
    image: ajeris/squid-analytics:latest
    container_name: squid-analytics
    restart: unless-stopped
    ports:
      - "8078:80"
    volumes:
      - ./logs:/var/log/squid:ro
      - ./squidanalyzer:/etc/squidanalyzer
      - ./apache-webdata:/var/www/html
    environment:
      - TZ=Asia/Qyzylorda
    healthcheck:
      test: ["CMD", "apache2ctl", "configtest"]
      interval: 30s
      timeout: 10s
      retries: 3
```

3. Bring it up:

```bash
docker-compose up -d
```

4. Access the web UI:

- Main: `http://<container-ip>/`
- Reports (SquidAnalyzer): `http://<container-ip>/squidanalyzer/`
- Real-time (SqStat): `http://<container-ip>/sqstat/`

> **Note:** With macvlan, access the container from your LAN (host-to-container access may be restricted by design).

---

## ⚙️ What Happens on First Run

When mounted directories are empty, the container automatically:

- Copies SquidAnalyzer default configs to `/etc/squidanalyzer` (host: `./squidanalyzer`)
- Copies SquidAnalyzer web resources (CSS/JS/images) to `/var/www/html/squidanalyzer`
- Deploys SqStat app into `/var/www/html/sqstat`
- Creates a landing page at `/var/www/html/index.html`

---

## 📁 Directory Structure (after first run)

```
./                      # project root on host
├── docker-compose.yml
├── logs/               # bind-mounted Squid logs (read-only)
│   ├── access.log
│   └── cache.log
├── squidanalyzer/      # SquidAnalyzer configs (persisted)
│   ├── squidanalyzer.conf
│   ├── network-aliases
│   ├── url-aliases
│   ├── user-aliases
│   ├── excluded
│   ├── included
│   └── lang/
│       ├── en_US.txt
│       ├── ru_RU.txt
│       └── ...
└── apache-webdata/
    ├── index.html
    ├── squidanalyzer/
    │   ├── squidanalyzer.css
    │   ├── flotr2.js
    │   ├── sorttable.js
    │   ├── images/
    │   ├── 20YY/
    │   └── index.html
    └── sqstat/
        ├── sqstat.php
        ├── sqstat.class.php
        ├── config.inc.php
        ├── sqstat.css
        └── ...
```

---

## 🧩 Configuration

### SquidAnalyzer (`./squidanalyzer/squidanalyzer.conf`)

```conf
LogFile /var/log/squid/access.log
Output /var/www/html/squidanalyzer
WebUrl /squidanalyzer
TopNumber 100
UserReport 1
UrlReport 1
TimeZone auto
```

### SqStat (`./apache-webdata/sqstat/config.inc.php`)

```php
$squidhost[0] = "192.168.10.11";
$squidport[0] = 8080;
$cachemgr_passwd[0] = "secret";
```

**Squid server config (`squid.conf`):**

```conf
acl monitoring_host src 192.168.10.22
http_access allow monitoring_host manager
http_access deny manager
cachemgr_passwd secret all
```

---

## 📊 Generating Reports

Manual parse:

```bash
docker exec -t squid-analytics squid-analyzer
```

Cron (host) — daily at 02:00:

```bash
00 02 * * * docker exec -t squid-analytics squid-analyzer > /dev/null 2>&1
```

If reports don’t appear, verify:

- Log path in `squidanalyzer.conf`
- File permissions (container must read mounted log)
- That `./logs` actually contains Squid access logs

---

## 🌐 Networking Notes

- **macvlan:** container gets its own LAN IP (port publishing not required)
- **bridge/host:** also supported — adjust `ports` and network mode as needed

---

## 🧰 Troubleshooting

- **SqStat shows only connection info (no tables):**  
  Check cachemgr ACLs and password match `config.inc.php`.

- **SquidAnalyzer page without styles/charts:**  
  ```bash
  docker exec squid-analytics cp -r /opt/squidanalyzer-resources/* /var/www/html/squidanalyzer/
  ```

- **No reports generated:**  
  ```bash
  docker exec -t squid-analytics squid-analyzer --debug
  ```

---

## 📜 License

This project bundles and configures open-source tools under their respective licenses:

- **SquidAnalyzer** — GPLv3 ([GitHub](https://github.com/darold/squidanalyzer))  
- **SqStat** — GPLv2 ([GitHub](https://github.com/CrashX/SqStat))

---

## Multi-Squid Server Setup

### Multiple Log Sources Support

SquidAnalyzer can process logs from multiple Squid servers simultaneously. This is useful for:
- **Multiple Docker hosts** with Squid containers
- **Users from same domain** but different subnets  
- **Centralized reporting** across distributed Squid infrastructure

### Configuration Options

**Option 1: Log Shipping (Recommended)**
```bash
# Use the provided sync script
./sync-logs.sh

# Or setup cron for automatic sync
*/10 * * * * /path/to/sync-logs.sh > /dev/null 2>&1
```

**Option 2: Network Mounts (NFS/CIFS)**
```yaml
# docker-compose.multi-squid.yml
volumes:
  - nfs-squid1:/var/log/squid1:ro
  - nfs-squid2:/var/log/squid2:ro
```

**Option 3: SSH File System (SSHFS)**
```bash
# Mount remote logs locally
sshfs user@squid-host1:/var/log/squid ./logs/squid1
sshfs user@squid-host2:/var/log/squid ./logs/squid2
```

### Multi-Log SquidAnalyzer Configuration

Edit `./squidanalyzer/squidanalyzer.conf`:
```conf
# Multiple log files (comma-separated)
LogFile /var/log/squid1/access.log,/var/log/squid2/access.log,/var/log/squid3/access.log

# Enable network reporting for subnet analysis
NetworkReport 1

# Store user IPs for cross-subnet user tracking
StoreUserIp 1
UseClientDNSName 0
```

### Network Aliases for Multi-Subnet

Edit `./squidanalyzer/network-aliases`:
```
# Format: network/mask friendly_name
192.168.10.0/24 Office Network Subnet1
192.168.20.0/24 Office Network Subnet2  
10.0.0.0/8 Internal Network
172.16.0.0/12 DMZ Network
```

### SqStat Multi-Server Configuration

Edit `./apache-webdata/sqstat/config.inc.php`:
```php
// Multiple Squid servers monitoring
$squidhost[0] = "192.168.10.11"; $squidport[0] = 8080; $cachemgr_passwd[0] = "secret";
$squidhost[1] = "192.168.10.12"; $squidport[1] = 8080; $cachemgr_passwd[1] = "secret"; 
$squidhost[2] = "192.168.20.10"; $squidport[2] = 3128; $cachemgr_passwd[2] = "secret";
```

### Benefits of Multi-Squid Setup

- ??? **Unified reporting** across all Squid instances
- ??? **Cross-subnet user tracking** (same domain users)
- ??? **Network-based analytics** with subnet grouping
- ??? **Real-time monitoring** of all servers via SqStat
- ??? **Centralized management** from single interface

