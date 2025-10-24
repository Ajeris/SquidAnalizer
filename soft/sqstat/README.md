# SQStat - Squid Proxy Real-time Statistics (Enhanced Version)

SQStat - это веб-приложение для мониторинга активности Squid прокси-сервера в реальном времени с расширенными возможностями.

## Особенности этой версии

✅ **Исправлено обрезание URL** - корректная работа настройки `SQSTAT_SHOWLEN` для всех типов URI  
✅ **Добавлена колонка Speed** - отображение скорости загрузки в Mbit/s для каждого соединения  
✅ **Суммарная скорость** - общая пропускная способность всех соединений в строке Total  
✅ **Правильный часовой пояс** - время "Created at:" соответствует часовому поясу сервера  
✅ **Поддержка HTTPS/FTP** - корректное отображение ссылок для https:// и ftp:// URL  

## Требования

- **OS**: Debian 12 (Bookworm) или совместимая
- **Web-сервер**: Apache2 или Nginx
- **PHP**: 7.4+ (рекомендуется 8.1+)
- **Squid**: 3.0+ с включенным cachemgr

## Установка на Debian 12

### 1. Установка необходимых пакетов

```bash
# Обновляем систему
sudo apt update && sudo apt upgrade -y

# Устанавливаем Apache2, PHP и необходимые модули
sudo apt install apache2 php libapache2-mod-php squid -y

# Включаем и запускаем Apache2
sudo systemctl enable apache2
sudo systemctl start apache2
```

### 2. Настройка Squid

Отредактируйте конфигурацию Squid:

```bash
sudo nano /etc/squid/squid.conf
```

Добавьте или раскомментируйте строки:

```conf
# Разрешить доступ к cachemgr с локального сервера
http_access allow localhost manager
http_access deny manager

# Настройка cachemgr
cachemgr_passwd secret_password all
```

Перезапустите Squid:

```bash
sudo systemctl restart squid
sudo systemctl enable squid
```

### 3. Установка SQStat

```bash
# Переходим в директорию веб-сервера
cd /var/www/html/

# Создаем директорию для sqstat
sudo mkdir sqstat
cd sqstat

# Копируем файлы sqstat (предполагая, что они у вас есть)
# Или скачиваем и распаковываем архив
sudo cp /path/to/your/sqstat/files/* .

# Устанавливаем правильные права доступа
sudo chown -R www-data:www-data /var/www/html/sqstat/
sudo chmod 644 *.php *.js *.css
```

### 4. Настройка конфигурации

Отредактируйте файл конфигурации:

```bash
sudo nano /var/www/html/sqstat/config.inc.php
```

Основные параметры для настройки:

```php
<?php
/* global settings */

$use_js=true; // использовать JavaScript для HTML toolkits

// Максимальная длина URL для отображения в таблице
DEFINE("SQSTAT_SHOWLEN", 40);

// Часовой пояс для отображения времени (опционально, определяется автоматически)
// Примеры: "Europe/Moscow", "America/New_York", "Asia/Tokyo"
DEFINE("SQSTAT_TIMEZONE", "Asia/Qyzylorda");

/* Настройки прокси */

/* IP-адрес или имя хоста Squid прокси-сервера */
$squidhost[0]="127.0.0.1";  // или ваш IP
/* Порт Squid прокси-сервера */
$squidport[0]=3128;         // стандартный порт Squid
/* Пароль cachemgr из squid.conf */
$cachemgr_passwd[0]="secret_password";
/* Разрешать IP-адреса или показывать только цифры [true|false] */
$resolveip[0]=false;
/* Группировать пользователей по hostname="host" или по User="username" */
$group_by[0]="username";    // или "host"

?>
```

### 5. Проверка установки

Откройте в браузере:

```
http://your-server-ip/sqstat/
```

## Настройка часового пояса

### Автоматическое определение

По умолчанию SQStat автоматически определяет часовой пояс системы. Для изменения системного часового пояса:

```bash
# Просмотр текущего часового пояса
timedatectl status

# Список доступных часовых поясов
timedatectl list-timezones | grep Europe

# Установка часового пояса (например, Москва)
sudo timedatectl set-timezone Europe/Moscow
```

### Ручная настройка

Для точной настройки отредактируйте `config.inc.php`:

```php
// Раскомментируйте и установите нужный часовой пояс
DEFINE("SQSTAT_TIMEZONE", "Europe/Moscow");
```

## Описание новых функций

### 1. Колонка Speed

- Отображает скорость загрузки для каждого соединения в Mbit/s
- Рассчитывается на основе объема данных и времени соединения
- Формула: `(bytes / 1024 / seconds) * 8 / 1024 = Mbit/s`
- Отображается "-" для соединений без данных о времени

### 2. Суммарная скорость в строке Total

Строка Total теперь показывает:
- **С сессиями**: `Total: X users and Y connections @ Z.Z/W.W KB/s (CURR/AVG), Speed: XX.XX Mbit/s`
- **Без сессий**: `Total: X users and Y connections, Speed: XX.XX Mbit/s`

### 3. Улучшенное обрезание URL

- Настройка `SQSTAT_SHOWLEN` теперь работает для всех типов URI
- Поддержка http://, https://, ftp:// и обычного текста
- Добавление "..." для обрезанных URL

## Структура таблицы

```
User/IP | URI | [Curr. Speed] | [Avg. Speed] | Size | Speed | Time
```

Где:
- `User/IP`: Имя пользователя или IP-адрес
- `URI`: URL запроса (обрезанный согласно SQSTAT_SHOWLEN)
- `Curr. Speed / Avg. Speed`: Текущая и средняя скорости (если включены сессии)
- `Size`: Размер переданных данных
- `Speed`: Скорость соединения в Mbit/s (**новая колонка**)
- `Time`: Время соединения

## Устранение неполадок

### Squid недоступен
- Проверьте, запущен ли Squid: `sudo systemctl status squid`
- Проверьте настройки firewall: `sudo ufw status`
- Проверьте конфигурацию в `/etc/squid/squid.conf`

### Неправильное время
- Проверьте системное время: `date`
- Проверьте часовой пояс: `timedatectl status`
- Настройте `SQSTAT_TIMEZONE` в `config.inc.php`

### Ошибки PHP
- Проверьте логи: `sudo tail -f /var/log/apache2/error.log`
- Убедитесь, что PHP модуль загружен: `php -m`

### Права доступа
```bash
sudo chown -R www-data:www-data /var/www/html/sqstat/
sudo chmod 644 /var/www/html/sqstat/*.php
```

## Файлы конфигурации

- `config.inc.php` - основная конфигурация
- `sqstat.php` - главный файл приложения
- `sqstat.class.php` - основной класс с логикой

## Версия и лицензия

- **Версия**: 1.20 (Enhanced)
- **Оригинальный автор**: Alex Samorukov (samm@os2.kiev.ua)
- **Улучшения**: 2025

## Поддержка

При возникновении проблем проверьте:
1. Логи Apache: `/var/log/apache2/error.log`
2. Логи Squid: `/var/log/squid/access.log`
3. Конфигурацию Squid: `/etc/squid/squid.conf`
4. Настройки SQStat: `config.inc.php`
