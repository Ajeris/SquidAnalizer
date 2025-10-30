#!/bin/bash
set -e

echo "[INFO] Starting Apache with Squid Log Analyzers..."

# Ensure required directories exist
mkdir -p /var/www/html/squidanalyzer \
         /var/www/html/sqstat \
         /var/log/squidanalyzer \
         /etc/squidanalyzer

echo "[INFO] Directories checked and created if missing."

# Initialize SquidAnalyzer config if directory is empty
if [ -d "/etc/squidanalyzer" ] && [ -z "$(ls -A /etc/squidanalyzer)" ]; then
    echo "[INFO] SquidAnalyzer config directory is empty, copying default configuration..."
    if [ -d "/opt/squidanalyzer-defaults" ]; then
        cp -r /opt/squidanalyzer-defaults/* /etc/squidanalyzer/
        echo "[INFO] Default SquidAnalyzer configuration files copied."
    # Copy language files if they exist
    if [ -d "/opt/squidanalyzer-defaults/lang" ] && [ ! -d "/etc/squidanalyzer/lang" ]; then
        cp -r /opt/squidanalyzer-defaults/lang /etc/squidanalyzer/
        echo "[INFO] Default SquidAnalyzer language files copied."
    fi
    else
        echo "[WARN] Default SquidAnalyzer config source not found"
    fi
fi

# Copy SquidAnalyzer resources (CSS, JS, images) if missing
if [ ! -f "/var/www/html/squidanalyzer/squidanalyzer.css" ] && [ -d "/opt/squidanalyzer-resources" ]; then
    echo "[INFO] Copying SquidAnalyzer resources (CSS, JS, images)..."
    cp -r /opt/squidanalyzer-resources/* /var/www/html/squidanalyzer/ 2>/dev/null || true
    echo "[INFO] SquidAnalyzer resources copied."
fi

# Deploy SqStat if target directory is empty or missing key files
if [ ! -f "/var/www/html/sqstat/sqstat.php" ] || [ ! -f "/var/www/html/sqstat/config.inc.php" ]; then
    echo "[INFO] Deploying SqStat (missing files detected)..."
    if [ -d "/opt/sqstat-defaults" ]; then
        cp -r /opt/sqstat-defaults/* /var/www/html/sqstat/ 2>/dev/null && true
        echo "[INFO] SqStat files deployed from embedded defaults."
    else
        echo "[WARN] Default SqStat files not found in container"
    fi
else
    echo "[INFO] SqStat files already present, skipping deployment."
fi

# Initialize default web content if main index doesn't exist
INDEX_PAGE="/var/www/html/index.html"
if [ ! -f "$INDEX_PAGE" ]; then
    echo "[INFO] Creating Squid analysis landing page..."
    cat > "$INDEX_PAGE" << 'HTML'
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
        .direct-links a:hover { text-decoration: underline; }
        .status {
            background: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Squid Log Analysis Tools</h1>
        <p class="subtitle">Welcome to the Squid log analysis interface</p>
        
        <div class="status">
            <strong>Status:</strong> Container initialized successfully
        </div>
        
        <div class="direct-links">
            <strong>Quick Access:</strong><br>
            <a href="/sqstat/" target="_blank">SqStat Dashboard</a> | 
            <a href="/squidanalyzer/" target="_blank">SquidAnalyzer Reports</a>
        </div>

        <div style="text-align: center;">
            <div class="link-box" onclick="window.open('/sqstat/', '_blank')">
                <h3>SqStat</h3>
                <p>Real-time monitoring dashboard<br>Live connections and bandwidth</p>
            </div>
            <div class="link-box" onclick="window.open('/squidanalyzer/', '_blank')">
                <h3>SquidAnalyzer</h3>
                <p>Comprehensive log analysis<br>Daily, weekly, monthly reports</p>
            </div>
        </div>
    </div>
</body>
</html>
HTML
else
    echo "[INFO] index.html already exists ??? skip."
fi

# Fix permissions
chown -R www-data:www-data /var/www/html /var/log/squidanalyzer
chmod -R 755 /var/www/html

# Set proper permissions for SquidAnalyzer config
if [ -d "/etc/squidanalyzer" ]; then
    chown -R root:root /etc/squidanalyzer
    chmod -R 644 /etc/squidanalyzer
    find /etc/squidanalyzer -type d -exec chmod 755 {} \;
fi

echo "[INFO] Testing Apache configuration..."
if apache2ctl configtest; then
    echo "[INFO] Apache configuration is valid. Launching..."
else
    echo "[ERROR] Apache configuration test failed!"
    exit 1
fi

exec "$@"
