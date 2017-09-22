FROM devgeniem/openresty-pagespeed
MAINTAINER Onni Hakala <onni.hakala@geniem.com>

##
# Only use these during installation
##
ARG LANG=C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive

##
# Install php7 packages from dotdeb.org
# - Dotdeb is an extra repository providing up-to-date packages for your Debian servers
##
RUN \
    apt-get update \
    && apt-get -y --no-install-recommends install \
        curl \
        nano \
        ca-certificates \
        git \
        mysql-client \
        msmtp \
        netcat \
        less \
        libmcrypt-dev \
    && echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list \
    && curl -sS https://www.dotdeb.org/dotdeb.gpg | apt-key add - \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        php7.0-cli \
        php7.0-common \
        php7.0-apcu \
        php7.0-apcu-bc \
        php7.0-curl \
        php7.0-json \
        php7.0-mcrypt \
        php7.0-opcache \
        php7.0-readline \
        php7.0-xml \
        php7.0-zip \
        php7.0-fpm \
        php7.0-redis \
        php7.0-mongodb \
        php7.0-mysqli \
        php7.0-intl \
        php7.0-gd \
        php7.0-mbstring \
        php7.0-soap \
        php7.0-bcmath \
        php7.0-curl \
        php7.0-ldap \
        php7.0-mcrypt \
        php7.0-imagick \
        libmagickwand-dev \

    # Force install only cron without extra mailing dependencies
    && cd /tmp \
    && apt-get download cron \
    && dpkg --force-all -i cron*.deb \
    && mkdir -p /var/spool/cron/crontabs \

    # Cleanup
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /var/log/apt/* /var/log/*.log


# Install helpers
RUN \
    ##
    # Install composer
    ##
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require hirak/prestissimo \

    ##
    # Install wp-cli
    # source: http://wp-cli.org/
    ##
    && curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp-cli \
    && chmod +rx /usr/local/bin/wp-cli \
    # Symlink it to /usr/bin as well so that cron can find this script with limited PATH
    && ln -s /usr/local/bin/wp-cli /usr/bin/wp-cli \

    ##
    # Install cronlock for running cron correctly with multi container setups
    # https://github.com/kvz/cronlock
    ##
    && curl -L https://raw.githubusercontent.com/kvz/cronlock/master/cronlock -o /usr/local/bin/cronlock \
    && chmod +rx /usr/local/bin/cronlock \
    # Symlink it to /usr/bin as well so that cron can find this script with limited PATH
    && ln -s /usr/local/bin/cronlock /usr/bin/cronlock

##
# Add Project files like nginx and php-fpm processes and configs
# Also custom scripts and bashrc
##
COPY rootfs/ /

# Run small fixes
RUN set -x \
    && mkdir -p /var/www/uploads \
    && ln -sf /usr/sbin/php-fpm7.0 /usr/sbin/php-fpm \
    && ln -sf /usr/bin/wp /usr/local/bin/wp

# This is for your project root
ENV PROJECT_ROOT="/var/www/project"

ENV \

    # Add interactive term
    TERM="xterm" \

    # Set defaults which can be overriden
    MYSQL_PORT="3306" \

    # Use default web port in nginx but allow it to be overridden
    # This also works correctly with flynn:
    # https://github.com/flynn/flynn/issues/3213#issuecomment-237307457
    PORT="8080" \

    # Use custom users for nginx and php-fpm
    WEB_USER="wordpress" \
    WEB_GROUP="web" \
    WEB_UID=1000 \
    WEB_GID=1001 \

    # Set defaults for redis
    REDIS_PORT="6379" \
    REDIS_DATABASE="0" \
    REDIS_PASSWORD="" \
    REDIS_SCHEME="tcp" \

    # Set defaults for NGINX redis cache
    # This variable uses seconds by default
    # Time units supported are "s"(seconds), "ms"(milliseconds), "y"(years), "M"(months), "w"(weeks), "d"(days), "h"(hours), and "m"(minutes).
    NGINX_REDIS_CACHE_TTL_DEFAULT="900" \
    NGINX_REDIS_CACHE_TTL_MAX="4h" \

    # Cronlock is used to stop simultaneous cronjobs in clusterised environments
    CRONLOCK_HOST="" \

    # This is used by nginx and php-fpm
    WEB_ROOT="${PROJECT_ROOT}/web" \
    # This is used automatically by wp-cli
    WP_CORE="${PROJECT_ROOT}/web/wp" \

    # Nginx include files
    NGINX_INCLUDE_DIR="/var/www/project/nginx" \
    # Allow bigger file uploads
    NGINX_MAX_BODY_SIZE="10M" \
    # Allow storing bigger body in memory
    NGINX_BODY_BUFFER_SIZE="32k" \
    # Have sane fastcgi timeout by default
    NGINX_FASTCGI_TIMEOUT="30" \

    # Have sane fastcgi timeout by default
    NGINX_ERROR_LEVEL="warn" \
    # Have sane fastcgi timeout by default
    NGINX_ERROR_LOG="stderr" \
    # Have sane fastcgi timeout by default
    NGINX_ACCESS_LOG="/dev/stdout" \

    # Default cache key for nginx http cache
    NGINX_CACHE_KEY='wp_:nginx:$real_scheme$request_method$host$request_uri' \

    # PHP settings
    PHP_MEMORY_LIMIT="128M" \
    PHP_MAX_INPUT_VARS="1000" \
    PHP_ERROR_LOG="/proc/self/fd/1" \
    PHP_ERROR_LOG_LEVEL="warning" \
    PHP_ERROR_LOG_MAX_LEN="8192" \
    PHP_SESSION_REDIS_DB="0" \
    PHP_SESSION_HANDLER="files" \

    # You should count the *.php files in your project and set this number to be bigger
    # $ find . -type f -print | grep php | wc -l
    PHP_OPCACHE_MAX_FILES="8000" \

    # Amount of memory in MB to allocate for opcache
    PHP_OPCACHE_MAX_MEMORY="128" \

    # Use host machine as default SMTP_HOST
    SMTP_HOST="172.17.0.1" \

    # This folder is used to mount files into host machine
    # You should use this path for your uploads since everything else should be ephemeral
    UPLOADS_ROOT="/var/www/uploads" \

    # This can be overidden by you, it's just default for us
    TZ="Europe/Helsinki"

# Setup $TZ. Remember to run this again in your own build
RUN dpkg-reconfigure tzdata && \
    # Make sure that all files here have execute permissions
    chmod +x /etc/cont-init.d/*

# Set default path to project folder for easier running commands in project
WORKDIR ${PROJECT_ROOT}

EXPOSE ${PORT}

ENTRYPOINT ["/init"]

