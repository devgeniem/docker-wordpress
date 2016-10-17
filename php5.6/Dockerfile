FROM alpine:edge
MAINTAINER Onni Hakala - Geniem Oy. <onni.hakala@geniem.com>

# Install dependencies and small amount of devtools
RUN apk add --update curl bash nano nginx ca-certificates \
    # Libs for php
    libssh2 libpng freetype libjpeg-turbo libgcc libxml2 libstdc++ icu-libs libltdl libmcrypt \
    # WP-CLI will try to use interactive mode and causes few errors in output
    # when ncurses is not installed
    ncurses \
    # For mails
    msmtp \
    # Install gettext
    gettext \
    # For mysql import/export
    mysql-client \
    # Set timezone according your location
    tzdata \

    ##
    # PHP 5.X
    ##
    php5 php5-fpm php5-json php5-zlib php5-xml php5-pdo php5-phar php5-openssl \
    php5-pdo_mysql php5-mysqli php5-gd php5-mcrypt php5-curl php5-opcache php5-ctype  \
    php5-intl php5-bcmath php5-dom php5-xmlreader php5-apcu php5-mysql php5-iconv && \

    # Small fixes to php & nginx
    ln -s /etc/php5 /etc/php && \
    ln -s /usr/lib/php5 /usr/lib/php && \
    mkdir -p /var/log/php/ && \

    # Create directory for msmtp mail logging
    mkdir -p /var/log/mail && \

    # Upgrade musl
    apk add -u musl && \

    # Remove nginx user because we will create a user with correct permissions dynamically
    deluser nginx && \
    mkdir -p /var/log/nginx && \
    mkdir -p /tmp/nginx/body && \

    # Remove default localhost folder
    rm -rf /var/www/localhost && \

    # Create uploads folder and project folder
    mkdir -p /var/www/uploads && \
    mkdir -p /var/www/project/web && \

    # Remove default crontab
    rm /var/spool/cron/crontabs/root && \

    ##
    # Add S6-overlay to use S6 process manager
    # source: https://github.com/just-containers/s6-overlay/#the-docker-way
    ##
    curl -L https://github.com/just-containers/s6-overlay/releases/download/v1.17.2.0/s6-overlay-amd64.tar.gz \
    | tar -xvzC /  && \

    ##
    # Install wp-cli
    # source: http://wp-cli.org/
    ##
    curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp-cli && \
    chmod +rx /usr/local/bin/wp-cli && \
    # Install Depencies for wp-cli
    # - It uses less internally to output help pages
    apk add less && \

    ##
    # Install cronlock for running cron correctly with mulitple container setups
    # https://github.com/kvz/cronlock
    ##
    curl -L https://raw.githubusercontent.com/kvz/cronlock/master/cronlock -o /usr/local/bin/cronlock && \
    chmod +rx /usr/local/bin/cronlock && \

    # Remove cache and tmp files
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

##
# Add Project files like nginx and php-fpm processes and configs
# Also custom scripts and bashrc
##
COPY rootfs/ /

# Update path with composer files + wpcs
ENV TERM="xterm" \
    DB_HOST="" \
    DB_NAME="" \
    DB_USER=""\
    DB_PASSWORD=""\
    # Set defaults which can be overriden
    DB_PORT="3306" \
    # Use default web port in nginx but allow it to be overridden
    # This also works correctly with flynn:
    # https://github.com/flynn/flynn/issues/3213#issuecomment-237307457
    PORT="80" \
    # Set defaults for redis
    WP_REDIS_PORT="6379" \
    WP_REDIS_DATABASE="0" \
    WP_REDIS_SCHEME="tcp" \
    WP_REDIS_CLIENT="pecl" \
    # Cronlock is used to stop simultaneous cronjobs in clusterised environments
    CRONLOCK_HOST="" \
    # This is for your project root
    PROJECT_ROOT="/var/www/project" \
    # This is used by nginx and php-fpm
    WEB_ROOT="/var/www/project/web" \
    # Nginx include files
    NGINX_INCLUDE_DIR="/var/www/project/nginx" \
    # Allow bigger file uploads
    NGINX_MAX_BODY_SIZE="64M" \
    # Have sane fastcgi timeout by default
    NGINX_FASTCGI_TIMEOUT="30" \

    # Default php memory limit
    PHP_MEMORY_LIMIT="128M" \

    # This is used automatically by wp-cli
    WP_CORE="/var/www/project/web/wp"\
    # Use host machine as default SMTP_HOST
    SMTP_HOST="172.17.0.1" \
    # This folder is used to mount files into host machine
    # You should use this path for your uploads since everything else should be ephemeral
    UPLOADS_ROOT="/var/www/uploads"\
    # This can be overidden by you, it's just default for us
    TZ="Europe/Helsinki"

# Set default path to project folder for easier running commands in project
WORKDIR ${PROJECT_ROOT}

EXPOSE ${PORT}

ENTRYPOINT ["/init"]
