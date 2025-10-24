# Squid Log Analyzer Container

Optimized Docker container for Squid log analytics using **SquidAnalyzer
v6.6** and **SqStat** on **Debian 12-slim** with a preconfigured Apache2
web server.

[![Docker
Build](https://img.shields.io/badge/docker-build-blue.svg)](https://docker.com)
[![Debian
12](https://img.shields.io/badge/base-Debian%2012--slim-lightgrey)](https://www.debian.org/)
[![SquidAnalyzer](https://img.shields.io/badge/SquidAnalyzer-6.6-success)](https://github.com/darold/squidanalyzer)
[![SqStat](https://img.shields.io/badge/SqStat-latest-brightgreen)](https://github.com/CrashX/SqStat/)

------------------------------------------------------------------------

## Overview

This container extends Squid deployments with high-performance log
analytics and real-time traffic visualization.\
It is designed to work as a **companion** to the main
**squid-docker-debian** proxy server setup.

Included tools:

-   **SquidAnalyzer v6.6**
    -   Compiled from source for performance and log format
        compatibility\
    -   Generates daily, weekly, and monthly traffic reports
    -   Source: https://github.com/darold/squidanalyzer
-   **SqStat**
    -   Real-time monitoring dashboard running on Apache2
    -   Live connections, bandwidth, and user visibility
    -   Source: https://github.com/CrashX/SqStat/

⚡ Minimal system footprint • Automated report generation • Easy
deployment

------------------------------------------------------------------------

## Features

  Feature                            Supported
  --------------------------------- -----------
  Squid log analytics                   ✅
  Real-time traffic dashboard           ✅
  Apache2 web interface                 ✅
  Log rotation awareness                ✅
  Custom volume mounts                  ✅
  Works alongside Squid container       ✅

------------------------------------------------------------------------

## Docker Volumes

  Path Inside Container            Description
  -------------------------------- ---------------------------
  `/var/log/squid/`                Mounted Squid access logs
  `/var/www/html/squidanalyzer/`   Generated HTML reports
  `/var/www/html/sqstat/`          Live monitoring pages

------------------------------------------------------------------------

## Usage (Docker CLI)

``` bash
docker run -d --name squid-analytics   -p 8080:80   -v /path/to/squid/logs:/var/log/squid   ajeris/squid-analytics:latest
```

Then open in browser:\
👉 http://localhost:8080\
→ SquidAnalyzer: `/squidanalyzer/`\
→ SqStat: `/sqstat/`

------------------------------------------------------------------------

## Docker Compose Example

``` yaml
services:
  squid-analytics:
    image: ajeris/squid-analytics:latest
    container_name: squid-analytics
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./logs:/var/log/squid
```

------------------------------------------------------------------------

## Roadmap

-   Add authentication for Web UI
-   Add Grafana export support
-   Auto-sync logs from remote Squid nodes
-   Dark theme for dashboards 🎨

------------------------------------------------------------------------

## License

This project uses open source packages under their respective licenses\
See:\
- SquidAnalyzer --- GPLv3\
- SqStat --- GPLv2

------------------------------------------------------------------------

If you use this project, consider leaving a ⭐ on GitHub!
