# Changelog

## Version 2.4 (Current)

### ??? Fixed Issues
- **SqStat**: Updated to working version with proper functionality
- **SquidAnalyzer**: Fixed CSS/JS/images display issues
- **Network**: Configured macvlan for Squid server connectivity
- **Auto-initialization**: Both tools deploy automatically on container start

### ???? Configuration
- **macvlan network**: Container gets IP 192.168.10.22 for direct server access
- **SqStat**: Default config points to 127.0.0.1:3128 (customize as needed)
- **SquidAnalyzer**: Auto-copies resources (CSS, JS, images) on startup
- **Port mapping**: Commented out (not needed with macvlan)

### ???? File Structure
```
squid-analytics/
????????? docker-compose.yml          # macvlan configuration
????????? Dockerfile                  # v2.4 with updated SqStat
????????? README.md                   # Complete documentation
????????? QUICKSTART.md              # Simple setup guide
????????? soft/sqstat/               # Updated working SqStat version
```

### ???? Usage
- **Direct access**: http://192.168.10.22/
- **SquidAnalyzer**: http://192.168.10.22/squidanalyzer/
- **SqStat**: http://192.168.10.22/sqstat/

### ???? Requirements Met
- ??? Self-contained Docker image
- ??? Automatic resource deployment
- ??? Working SqStat with table display
- ??? Working SquidAnalyzer with styling
- ??? macvlan network for server connectivity
- ??? Automated report generation via cron

## Previous Versions

### Version 2.3
- Added SquidAnalyzer resource copying
- Fixed CSS/JS display issues

### Version 2.2  
- Added self-contained configuration
- Embedded default files in image

### Version 2.1
- Initial configuration automation

