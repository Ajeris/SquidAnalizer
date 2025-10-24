# Apache with Squid Log Analyzers based on Debian with Apache2
FROM debian:bookworm-slim

# Метаданные образа
LABEL maintainer="Ajeris"
LABEL description="Apache server with SquidAnalyzer and SqStat for Squid log analysis"
LABEL version="2.0"

# Устанавливаем переменные окружения
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Qyzylorda

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y \
    # Apache2
    apache2 \
    # Зависимости для SqStat
    libapache2-mod-php \
    php \
    php-cli \
    php-common \
    php-json \
    php-mbstring \
    # Зависимости для SquidAnalyzer
    perl \
    make \
    libgd-graph-perl \
    libgd-text-perl \
    libhtml-template-perl \
    liburi-perl \
    libcompress-zlib-perl \
    libdbd-pg-perl \
    libdbi-perl \
    # Утилиты
    curl \
    && rm -rf /var/lib/apt/lists/*

# Включаем PHP модуль
RUN a2enmod php8.2

# Создаём рабочие директории
RUN mkdir -p /var/www/html/squidanalyzer \
    && mkdir -p /var/www/html/sqstat \
    && mkdir -p /var/log/squidanalyzer \
    && mkdir -p /etc/squidanalyzer \
    && mkdir -p /opt/soft

# Копируем исходные коды программ
COPY soft/ /opt/soft/

# Устанавливаем SquidAnalyzer
WORKDIR /opt/soft
RUN if [ -d "squidanalyzer-master" ]; then \
        cd squidanalyzer-master && \
        perl Makefile.PL INSTALLDIRS=site && \
        make && make install; \
    else \
        echo "Warning: SquidAnalyzer not found in soft/ directory"; \
    fi

# Копируем Apache конфигурации для SqStat и SquidAnalyzer
COPY config/apache/ /etc/apache2/conf-available/

# Включаем конфигурации
RUN a2enconf sqstat && a2enconf squidanalyzer

# Копируем entrypoint скрипт
COPY apache/entrypoint-apache.sh /usr/local/bin/entrypoint-apache.sh
RUN chmod +x /usr/local/bin/entrypoint-apache.sh

# Устанавливаем права доступа
RUN chown -R www-data:www-data /var/www/html \
    && chown -R www-data:www-data /var/log/squidanalyzer \
    && chmod -R 755 /var/www/html

# Создаем базовую конфигурацию Apache
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Открываем порты
EXPOSE 80 443

# Том для логов squid
VOLUME ["/var/log/squid", "/var/www/html"]

# Запускаем entrypoint скрипт
ENTRYPOINT ["/usr/local/bin/entrypoint-apache.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
