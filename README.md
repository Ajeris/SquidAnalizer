# Squid Log Analytics Container

An optimized Docker image providing Squid log analytics (SquidAnalyzer) and real???time monitoring (SqStat) on Debian 12-slim with Apache2.

Badges: Debian 12-slim ??? SquidAnalyzer 6.x ??? SqStat ??? Apache2 ??? Self???contained

---

## Overview

This container is designed to be a companion to an existing Squid deployment. It:
- Parses Squid access logs and generates daily/weekly/monthly HTML reports (SquidAnalyzer)
- Shows real-time connections, users, bandwidth, and targets (SqStat)
- Auto-initializes default configs and web assets on first run

---

## Features

- SquidAnalyzer reports (tables, charts, localization)
- SqStat real-time dashboard
- Apache2 web UI, zero-config on first start
- Volume-friendly: configs and web data persist on host
- Works with bridge/macvlan or alongside a Squid container

---

## Quick Start

1) Ensure you have Squid access logs available on the host (bind-mount to `./logs`).

2) docker-compose.yml (macvlan example with a static IP for the container):

```yaml
services:
  squid-analytics:
    image: squid-analytics:2.5
    container_name: squid-analytics
    restart: unless-stopped
    # ports:               # not required on macvlan
    #   - "8078:80"
    volumes:
      - ./logs:/var/log/squid:ro         # your Squid access logs
      - ./squidanalyzer:/etc/squidanalyzer
      - ./apache-webdata:/var/www/html
    environment:
      - TZ=Asia/Qyzylorda
    networks:
      squid-net:
        ipv4_address: 192.168.10.22

networks:
  squid-net:
    driver: macvlan
    driver_opts:
      parent: eth0   # replace with your host NIC
    ipam:
      config:
        - subnet: 192.168.10.0/24
          gateway: 192.168.10.1
          ip_range: 192.168.10.22/32
```

3) Bring it up:
```bash
docker-compose up -d
```

4) Access:
- Main: http://\<container-ip\>/
- Reports (SquidAnalyzer): http://\<container-ip\>/squidanalyzer/
- Real-time (SqStat): http://\<container-ip\>/sqstat/

> Note: With macvlan, access the container from your LAN (host-to-container access may be restricted by design).

---

## What Happens on First Run

The container automatically initializes defaults when mounted directories are empty:
- Copies SquidAnalyzer default configs to `/etc/squidanalyzer` (host: `./squidanalyzer`)
- Copies SquidAnalyzer web resources (CSS/JS/images) to `/var/www/html/squidanalyzer`
- Deploys SqStat app into `/var/www/html/sqstat`
- Creates a landing page at `/var/www/html/index.html`

---

## Directory Structure (after first run)

```
./                      # project root on host
????????? docker-compose.yml
????????? logs/               # bind-mounted Squid logs (read-only)
???   ????????? access.log
???   ????????? cache.log
????????? squidanalyzer/      # SquidAnalyzer configs (persisted)
???   ????????? squidanalyzer.conf      # main config (LogFile path, Output, options)
???   ????????? network-aliases         # CIDR -> name mappings
???   ????????? url-aliases             # URL grouping
???   ????????? user-aliases            # user/group aliases
???   ????????? excluded                # exclude filters
???   ????????? included                # include filters
???   ????????? lang/                   # localization files (12 languages)
???       ????????? en_US.txt
???       ????????? ru_RU.txt
???       ????????? ...
????????? apache-webdata/     # web root (persisted)
    ????????? index.html
    ????????? squidanalyzer/          # SquidAnalyzer web assets + generated HTML reports
    ???   ????????? squidanalyzer.css
    ???   ????????? flotr2.js
    ???   ????????? sorttable.js
    ???   ????????? images/
    ???   ????????? 20YY/               # reports by year/month/day (created after parsing)
    ???   ????????? index.html          # created after parsing
    ????????? sqstat/                 # SqStat real-time dashboard
        ????????? sqstat.php
        ????????? sqstat.class.php
        ????????? config.inc.php
        ????????? sqstat.css
        ????????? ...
```

---

## Configuration

### SquidAnalyzer (./squidanalyzer/squidanalyzer.conf)
Recommended key settings:
```conf
# Log path (container path; with provided compose, maps to ./logs on host)
LogFile /var/log/squid/access.log

# Output directory (container path)
Output /var/www/html/squidanalyzer

# Web URL prefix
WebUrl /squidanalyzer

# Optional tuning
TopNumber 100
UserReport 1
UrlReport 1
TimeZone auto
```
Localization is available via `./squidanalyzer/lang/` (automatically copied on first run).

### SqStat (./apache-webdata/sqstat/config.inc.php)
Set your Squid cachemgr endpoints:
```php
$squidhost[0] = "192.168.10.11";  $squidport[0] = 8080;  $cachemgr_passwd[0] = "secret";
// $group_by[0] = "username"; // or "host"
```
On each Squid server, allow cachemgr from the analytics container IP:
```conf
# squid.conf
acl monitoring_host src 192.168.10.22
http_access allow monitoring_host manager
http_access deny manager
cachemgr_passwd secret all
```

---

## Generating Reports (Parsing)

Manual parse:
```bash
docker exec -t squid-analytics squid-analyzer
```

Cron (host) ??? daily at 02:00:
```bash
crontab -e
00 02 * * * docker exec -t squid-analytics squid-analyzer > /dev/null 2>&1
```

If reports don???t appear, verify:
- Log path in `squidanalyzer.conf` (use `/var/log/squid/access.log`)
- File permissions (container must read the mounted log)
- That your `./logs` actually contains access logs

---

## Networking Notes

- macvlan: gives the container its own IP in your LAN. Port publishing is typically unnecessary.
- bridge/host: also supported; adjust `ports` and network mode as needed.

---

## Troubleshooting

- SqStat shows only connection info (no tables): ensure cachemgr is allowed from the container IP and credentials match `config.inc.php`.
- SquidAnalyzer page without styles/charts: resources are auto-copied; if missing, run:
  ```bash
  docker exec squid-analytics cp -r /opt/squidanalyzer-resources/* /var/www/html/squidanalyzer/
  ```
- No reports generated: run with debug
  ```bash
  docker exec -t squid-analytics squid-analyzer --debug
  ```

---

## License

This project bundles and configures open-source tools under their respective licenses:
- SquidAnalyzer ??? GPLv3 (https://github.com/darold/squidanalyzer)
- SqStat ??? GPLv2 (https://github.com/CrashX/SqStat/)

