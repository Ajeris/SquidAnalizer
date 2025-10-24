#!/bin/bash
set -e

echo "Starting Apache with Squid Log Analyzers..."

# Проверяем директории
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking directories..."

# Создаем базовые директории если они не существуют
mkdir -p /var/www/html/squidanalyzer
mkdir -p /var/www/html/sqstat
mkdir -p /var/log/squidanalyzer
mkdir -p /etc/squidanalyzer

# Проверяем конфигурацию SquidAnalyzer
if [ -d "/etc/squidanalyzer" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SquidAnalyzer configuration found."
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating SquidAnalyzer configuration..."
    mkdir -p /etc/squidanalyzer
fi

# Устанавливаем SqStat если есть исходники
if [ -d "/opt/soft/sqstat" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing/Updating SqStat..."
    cp -r /opt/soft/sqstat/* /var/www/html/sqstat/ 2>/dev/null || true
    
    # Обновляем конфигурацию SqStat для Docker
    if [ -f "/opt/soft/sqstat/config.inc.php" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Updating SqStat configuration for Docker..."
        cp /opt/soft/sqstat/config.inc.php /var/www/html/sqstat/config.inc.php
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SqStat source not found in /opt/soft/sqstat"
fi

# Создаем/обновляем индексную страницу
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating navigation page..."
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Squid Log Analyzers</title>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; margin-bottom: 10px; }
        .subtitle { text-align: center; color: #666; margin-bottom: 30px; }
        .link-box { 
            display: inline-block; 
            margin: 20px; 
            padding: 25px; 
            border: 2px solid #ddd; 
            border-radius: 8px; 
            text-decoration: none; 
            color: #333; 
            width: 300px;
            text-align: center;
            transition: all 0.3s ease;
        }
        .link-box:hover { 
            background-color: #f8f9fa; 
            border-color: #007bff;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .link-box h3 { margin: 0 0 10px 0; color: #007bff; }
        .link-box p { margin: 0; font-size: 14px; }
        .config-info { 
            background: #e9ecef; 
            padding: 15px; 
            border-radius: 5px; 
            margin: 20px 0; 
            font-size: 14px; 
        }
        .config-info strong { color: #495057; }
        .direct-links {
            text-align: center;
            margin: 20px 0;
            background: #fff3cd;
            padding: 15px;
            border-radius: 5px;
            border: 1px solid #ffeaa7;
        }
        .direct-links a {
            color: #856404;
            text-decoration: none;
            font-weight: bold;
            margin: 0 10px;
        }
        .direct-links a:hover {
            color: #533f01;
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Squid Log Analysis Tools</h1>
        <p class="subtitle">Welcome to the Squid log analysis interface</p>
        
        <div class="direct-links">
            <strong>Quick Access:</strong><br>
            <a href="/sqstat/" target="_blank">SqStat Dashboard</a> | 
            <a href="/squidanalyzer/" target="_blank">SquidAnalyzer Reports</a>
        </div>
        
        <div style="text-align: center;">
            <a href="/squidanalyzer/" class="link-box">
                <h3>SquidAnalyzer</h3>
                <p>Comprehensive Squid log analyzer with detailed reports and historical data</p>
            </a>
            
            <a href="/sqstat/" class="link-box">
                <h3>SqStat</h3>
                <p>Real-time PHP-based Squid statistics monitoring via cachemgr interface</p>
            </a>
        </div>
        
        <div class="config-info">
            <strong>Configuration Info:</strong><br>
            • Squid Host: squid-proxy-service (Docker service)<br>
            • Squid Ports: 3128 (HTTP), 3129 (HTTPS)<br>
            • CacheMgr Password: squid_stats<br>
            • Timezone: Asia/Qyzylorda
        </div>
        
        <hr style="margin: 30px 0;">
        <p style="text-align: center;"><small>Powered by Apache HTTP Server (Debian) in Docker</small></p>
    </div>
</body>
</html>
HTML

# Устанавливаем права доступа
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/log/squidanalyzer
chmod -R 755 /var/www/html

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Testing Apache configuration..."
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Apache configuration is valid. Starting Apache..."
    exec "$@"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Apache configuration test failed!"
    exit 1
fi
