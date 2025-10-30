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

------------------------------------------------------------------------

## Quick Deployment

### ???? Simple Setup (Recommended)

For most users, use the simplified deployment:

```bash
# Download and run 
curl -o docker-compose.yml https://raw.githubusercontent.com/ajeris/squid-monitoring/main/docker-compose.simple.yml
mkdir -p logs
# Copy your Squid logs to ./logs/ or edit docker-compose.yml
docker-compose up -d
```

**Access**: http://localhost:8080/

See [QUICKSTART.md](QUICKSTART.md) for detailed instructions.

### ??????? Development Setup

For development or customization:

```bash
git clone https://github.com/ajeris/squid-monitoring.git
cd squid-monitoring
./init-directories.sh  # Setup local directories
docker-compose up -d    # Use full development compose
```


------------------------------------------------------------------------

## Configuration Management

### Automatic Initialization

The container automatically handles both SquidAnalyzer and SqStat configuration:

- **First run**: Default configuration files are automatically deployed
- **Subsequent runs**: Uses existing configuration files 
- **Reset configuration**: Delete the respective directory, and defaults will be restored

### Quick Setup

Run the initialization script to set up directories and copy default configurations:

```bash
./init-directories.sh
```

### Directory Structure

After initialization, you'll have:

```
./squidanalyzer/          # SquidAnalyzer configuration (bind mounted)
????????? squidanalyzer.conf    # Main configuration file
????????? excluded              # URL exclusion patterns
????????? included              # URL inclusion patterns  
????????? network-aliases       # Network name mappings
????????? url-aliases          # URL alias definitions
????????? user-aliases         # User alias definitions

./apache-webdata/         # Web server content (bind mounted)
????????? index.html           # Main landing page
????????? sqstat/              # SqStat real-time dashboard
???   ????????? sqstat.php       # Main dashboard script
???   ????????? config.inc.php   # SqStat configuration
???   ????????? ...              # Other SqStat files
????????? squidanalyzer/       # SquidAnalyzer generated reports
    ????????? ...              # Generated HTML reports
```

### Configuration Editing

All configuration files are now directly accessible on the host system:

**SquidAnalyzer Configuration:**
- Edit: `./squidanalyzer/squidanalyzer.conf`
- Restart container to apply changes

**SqStat Configuration:**
- Edit: `./apache-webdata/sqstat/config.inc.php`
- Changes are applied immediately (PHP)

### Resetting Configuration

**Reset SquidAnalyzer configuration:**
```bash
docker-compose down
rm -rf ./squidanalyzer
docker-compose up -d
```

**Reset SqStat files:**
```bash
docker-compose down
rm -rf ./apache-webdata
docker-compose up -d
```

**Reset everything:**
```bash
docker-compose down
rm -rf ./squidanalyzer ./apache-webdata
docker-compose up -d
```


------------------------------------------------------------------------

## SquidAnalyzer Configuration & Automation

### Configuration Files

After first container run, SquidAnalyzer configuration files are available in `./squidanalyzer/`:

- **squidanalyzer.conf** - Main configuration file
- **excluded** - URL patterns to exclude from analysis  
- **included** - URL patterns to include in analysis
- **network-aliases** - Network name mappings
- **url-aliases** - URL alias definitions
- **user-aliases** - User alias mappings

### Basic Configuration

Edit the main configuration file:

```bash
nano ./squidanalyzer/squidanalyzer.conf
```

Key settings to review:

```bash
# Output directory (mounted from container)
Output /var/www/html/squidanalyzer

# Web URL path
WebUrl /squidanalyzer

# Log file path (mounted from host)
LogFile /var/log/squid/access.log

# Analysis options
TopNumber 100
TopUrlUser 10
UserReport 1
UrlReport 1

# Time zone
TimeZone auto
```

### Host System Setup for Automated Reports

To generate regular reports, configure cron on the **host system**:

#### 1. Install SquidAnalyzer on Host

```bash
# Download and install SquidAnalyzer on host
wget https://github.com/darold/squidanalyzer/archive/master.zip
unzip master.zip
cd squidanalyzer-master/
perl Makefile.PL INSTALLDIRS=site
make && sudo make install
```

#### 2. Configure Host SquidAnalyzer

```bash
# Edit host configuration to match container paths
sudo nano /etc/squidanalyzer/squidanalyzer.conf
```

Update paths to match your setup:

```bash
# Point to container's web directory (if using bind mount)
Output /path/to/your/project/apache-webdata/squidanalyzer

# Point to your Squid logs
LogFile /path/to/your/squid/logs/access.log

# Web URL (container accessible)
WebUrl /squidanalyzer
```

#### 3. Create Update Script

```bash
sudo nano /etc/squidanalyzer/statistic-update.sh
```

```bash
#!/bin/bash
# SquidAnalyzer update script

------------------------------------------------------------------------

## SquidAnalyzer Configuration

### Configuration Files

After first container run, edit configuration files in `./squidanalyzer/`:

- **squidanalyzer.conf** - Main configuration file
- **network-aliases** - Network name mappings (IP ranges to names)
- **excluded** - URL patterns to exclude from analysis
- **included** - URL patterns to include in analysis

### Basic Configuration

Edit the main configuration:

```bash
nano ./squidanalyzer/squidanalyzer.conf
```

Key settings to review:

```bash
# Output directory (container path)
Output /var/www/html/squidanalyzer

# Log file path (container path)
LogFile /var/log/squid/access.log

# Analysis options
TopNumber 100
UserReport 1
UrlReport 1

# Time zone
TimeZone auto
```

### Network Aliases Configuration

Edit network mappings for better reporting:

```bash
nano ./squidanalyzer/network-aliases
```

Example network aliases:

```bash
# Format: network_address/mask network_name
192.168.1.0/24 Office Network
10.0.0.0/8 Internal Network
172.16.0.0/12 DMZ Network
203.0.113.0/24 External Servers
```

### Automated Report Generation

Setup cron on the host system to generate reports daily:

```bash
crontab -e
```

Add line for daily report generation at 2 AM:

```bash
# Generate SquidAnalyzer reports daily at 2:00 AM
00 02 * * * docker exec -t squid-analytics squid-analyzer > /dev/null 2>&1
```

### Manual Report Generation

To generate reports manually:

```bash
# Generate reports now
docker exec -t squid-analytics squid-analyzer

# Generate with debug output
docker exec -t squid-analytics squid-analyzer --debug
```

### Verification

### Resource Files

SquidAnalyzer requires CSS, JavaScript, and image files for proper display. These are automatically copied to the web directory on container startup.

If reports display without styling, the resources may be missing. Manually copy them:

```bash
docker exec squid-analytics cp -r /opt/squidanalyzer-resources/* /var/www/html/squidanalyzer/
```


Check if reports are generated:

1. **Web Interface**: Visit http://localhost:8080/squidanalyzer/
2. **Files**: Check `./apache-webdata/squidanalyzer/` for HTML files
3. **Logs**: `docker-compose logs` to see container activity


------------------------------------------------------------------------

## SqStat Configuration

### Network Configuration

SqStat requires network access to Squid servers' cachemgr interface. The container is configured with macvlan network (IP: 192.168.10.22) to communicate with local Squid servers.

### SqStat Configuration File

Edit the SqStat configuration after first container run:

```bash
nano ./apache-webdata/sqstat/config.inc.php
```

Configure your Squid servers:

```php
<?php
/* Squid proxy server settings */

/* First Squid server */
$squidhost[0]="192.168.10.11";    // Squid server IP
$squidport[0]=8080;               // Squid port  
$cachemgr_passwd[0]="secret";     // cachemgr password (from squid.conf)
$resolveip[0]=false;              // Resolve IP to hostnames
$group_by[0]="username";          // Group by username or host

/* Additional servers */
$squidhost[1]="192.168.10.3"; 
$squidport[1]=8080;
$cachemgr_passwd[1]="secret";
$resolveip[1]=true;
$group_by[1]="host";
?>
```

### Squid Server Requirements

Each Squid server must allow cachemgr access. Add to `/etc/squid/squid.conf`:

```bash
# Allow cachemgr access from monitoring container
http_access allow localhost manager
acl monitoring_host src 192.168.10.22
http_access allow monitoring_host manager
http_access deny manager

# Set cachemgr password (use in SqStat config)
cachemgr_passwd secret_password all
```

### Network Configuration

Update docker-compose.yml network settings for your environment:

```yaml
networks:
  squid-net:
    driver: macvlan
    driver_opts:
      parent: eth0  # Change to your network interface
    ipam:
      config:
        - subnet: 192.168.10.0/24     # Your subnet
          gateway: 192.168.10.1       # Your gateway
          ip_range: 192.168.10.22/32  # Container IP
```

### Verification

1. **Test connectivity**: `docker exec squid-analytics ping 192.168.10.11`
2. **Test cachemgr**: `curl http://192.168.10.11:8080/squid-internal-mgr/`
3. **View SqStat**: http://localhost:8078/sqstat/

### Future Integration

This container is designed to work with dedicated Squid containers. For container-to-container communication, SqStat will connect to Squid services in the same Docker network.

