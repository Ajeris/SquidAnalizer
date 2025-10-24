#!/bin/bash
set -e

echo "[INFO] Starting Apache with Squid Log Analyzers..."

# Ensure required directories exist
mkdir -p /var/www/html/squidanalyzer \
         /var/www/html/sqstat \
         /var/log/squidanalyzer \
         /etc/squidanalyzer

echo "[INFO] Directories checked and created if missing."

# Deploy SqStat if source exists
if [ -d "/opt/soft/sqstat" ]; then
    echo "[INFO] Deploying SqStat..."
    rsync -a /opt/soft/sqstat/ /var/www/html/sqstat/ --exclude='.git' 2>/dev/null || true

    if [ -f "/opt/soft/sqstat/config.inc.php" ]; then
        echo "[INFO] Updating SqStat configuration..."
        cp /opt/soft/sqstat/config.inc.php /var/www/html/sqstat/config.inc.php
    fi
else
    echo "[WARN] SqStat source directory not found: /opt/soft/sqstat"
fi

# Create index page only once
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
    </div>
</body>
</html>
HTML
else
    echo "[INFO] index.html already exists — skip."
fi

# Fix permissions
chown -R www-data:www-data /var/www/html /var/log/squidanalyzer
chmod -R 755 /var/www/html

echo "[INFO] Testing Apache configuration..."
if apache2ctl configtest; then
    echo "[INFO] Apache configuration is valid. Launching..."
else
    echo "[ERROR] Apache configuration test failed!"
    exit 1
fi

exec "$@"
