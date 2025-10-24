#!/bin/sh
test ! -d "/usr/local/bin" && mkdir -p /usr/local/bin
test ! -d "/etc/squidanalyzer" && mkdir -p /etc/squidanalyzer
test ! -d "/etc/squidanalyzer/lang" && mkdir -p /etc/squidanalyzer/lang
test ! -d "/var/www/squidanalyzer" && mkdir -p /var/www/squidanalyzer
test ! -d "/var/www/squidanalyzer/images" && mkdir -p /var/www/squidanalyzer/images

test ! -d "/usr/local/man/man3" && mkdir -p /usr/local/man/man3

# Copy files that must not be overriden 
for file in squidanalyzer.conf network-aliases user-aliases url-aliases excluded included; do
if [ -r /etc/squidanalyzer/$file ]; then
	install -m 644 etc/$file /etc/squidanalyzer/$file.sample
else
	install -m 644 etc/$file /etc/squidanalyzer/$file
fi
done
install -m 755 squid-analyzer /usr/local/bin/
install -m 644 resources/sorttable.js /var/www/squidanalyzer/
install -m 644 resources/squidanalyzer.css /var/www/squidanalyzer/
install -m 644 resources/flotr2.js /var/www/squidanalyzer/
install -m 644 resources/images/logo-squidanalyzer.png /var/www/squidanalyzer/images/
install -m 644 resources/images/cursor.png /var/www/squidanalyzer/images/
install -m 644 resources/images/domain.png /var/www/squidanalyzer/images/
install -m 644 resources/images/back-arrow.png /var/www/squidanalyzer/images/
install -m 644 resources/images/info.png /var/www/squidanalyzer/images/
install -m 644 resources/images/network.png /var/www/squidanalyzer/images/
install -m 644 resources/images/user.png /var/www/squidanalyzer/images/
install -m 644 lang/* /etc/squidanalyzer/lang/
pod2text doc/SquidAnalyzer.pod README
pod2man doc/SquidAnalyzer.pod squid-analyzer.3

	install -m 644 squid-analyzer.3 /usr/local/man/man3/

echo "
-----------------------------------------------------------------------------
1. Modify your httpd.conf to allow access to HTML output like follow:
        Alias /squidreport /var/www/squidanalyzer
        <Directory /var/www/squidanalyzer>
            Options -Indexes FollowSymLinks MultiViews
	    AllowOverride None
            Order deny,allow
            Deny from all
            Allow from 127.0.0.1
        </Directory>
2. If necessary, give additional host access to SquidAnalyzer in httpd.conf.
   Restart and ensure that httpd is running.
3. Browse to http://my.host.dom/squidreport/ to ensure that things are working
   properly.
4. Setup a cronjob to run squid-analyzer daily:

     # SquidAnalyzer log reporting daily
     0 2 * * * /usr/local/bin/squid-analyzer > /dev/null 2>&1

or run it manually. For more information, see /README file.
-----------------------------------------------------------------------------
"
