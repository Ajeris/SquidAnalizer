# Apache with Squid Log Analyzers based on Debian with Apache2
FROM debian:bookworm-slim

# Image metadata
LABEL maintainer="Ajeris"
LABEL description="Apache server with SquidAnalyzer and SqStat for Squid log analysis"
LABEL version="2.0"

# Environment configuration
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Qyzylorda

# Install required packages
RUN apt-get update && apt-get install -y \
    # Apache2
    apache2 \
    # Dependencies for SqStat
    libapache2-mod-php \
    php \
    php-cli \
    php-common \
    php-json \
    php-mbstring \
    # Dependencies for SquidAnalyzer
    perl \
    make \
    libgd-graph-perl \
    libgd-text-perl \
    libhtml-template-perl \
    liburi-perl \
    libcompress-zlib-perl \
    libdbd-pg-perl \
    libdbi-perl \
    # Tools and utilities
    curl \
    && rm -rf /var/lib/apt/lists/*

# Enable PHP module
RUN a2enmod php8.2

# Create required directories
RUN mkdir -p /var/www/html/squidanalyzer \
    && mkdir -p /var/www/html/sqstat \
    && mkdir -p /var/log/squidanalyzer \
    && mkdir -p /etc/squidanalyzer \
    && mkdir -p /opt/soft

# Copy source packages for SquidAnalyzer and SqStat
COPY soft/ /opt/soft/

# Install SquidAnalyzer from source if present
WORKDIR /opt/soft
RUN if [ -d "squidanalyzer-master" ]; then \
        cd squidanalyzer-master && \
        perl Makefile.PL INSTALLDIRS=site && \
        make && make install; \
    else \
        echo "Warning: SquidAnalyzer source not found in soft/ directory"; \
    fi

# Copy Apache configuration for SqStat and SquidAnalyzer
COPY config/apache/ /etc/apache2/conf-available/

# Enable Apache configuration files
RUN a2enconf sqstat && a2enconf squidanalyzer

# Copy entrypoint script
COPY apache/entrypoint-apache.sh /usr/local/bin/entrypoint-apache.sh
RUN chmod +x /usr/local/bin/entrypoint-apache.sh

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chown -R www-data:www-data /var/log/squidanalyzer \
    && chmod -R 755 /var/www/html

# Set basic Apache configuration
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Expose HTTP/HTTPS ports
EXPOSE 80 443

# Define mount points
VOLUME ["/var/log/squid", "/var/www/html"]

# Define entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint-apache.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
