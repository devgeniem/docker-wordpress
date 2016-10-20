# Lightweight PHP-FPM & Nginx Docker Image for WordPress
[![devgeniem/alpine-wordpress docker image](http://dockeri.co/image/devgeniem/wordpress-server)](https://registry.hub.docker.com/u/devgeniem/wordpress-server/)

[![License](https://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

This is maintained repository. We use this project in production and recommend this for your projects too. This container doesn't have mysql or email, you need to provide them from elsewhere. This can be other container or your host machine.

I tried to include all build, test and project tools in [docker-alpine-wordpress](https://github.com/devgeniem/docker-alpine-wordpress) image. I think that more modular design is better for docker and security as well.

This project tries to be as minimal as possible and doesn't include anything that we don't absolutely need in the runtime.

## Aren't you only supposed to run one process per container?
We think that docker container should be small set of processes which provide one service rather than one clumsy process. This container uses [s6-overlay](https://github.com/just-containers/s6-overlay) in order to run php-fpm and nginx together.

## Container layout
Mount your wordpress project into:
```
/var/www/project
```

Your project should define web root in:
```
/var/www/project/web
```
This is the place where nginx will serve requests. This is compatible with [bedrock layout](https://github.com/roots/bedrock).

### Override project path
You can use `OVERRIDE_PROJECT_ROOT` variable to change project path with symlink.

For example in `Drone CI` all mounts are done into `/drone/src` folder and we use `OVERRIDE_PROJECT_ROOT=/drone/src/project` in our testing.

Container creates a symlink from /var/www/project into `$OVERRIDE_PROJECT_ROOT` which allows us to use custom path.

## User permissions
You can use `WP_GID` and `WP_UID` env to change web user and group.

If these are not set container will look for owner:group from files mounted in `/var/www/project/web/`.

If these files are owned by root user or root group the container will automatically use 100:101 as permissions instead. This is so that we won't never run nginx and php-fpm as root.

## Nginx includes
You can have custom nginx includes in your project mount `/var/www/project/nginx`.

**Include into http {} block:**
`/var/www/project/nginx/http/*.conf`

**Include into server {} block:**
`/var/www/project/nginx/server/*.conf`

See more in our [wp-project template](https://github.com/devgeniem/wp-project).

## Cron jobs
You can place cron file in `/var/www/project/tasks.cron`. This is symlinked to crond and run as user `wordpress`.

For example:
```
# do daily/weekly/monthly maintenance
*       *       *       *       *       echo "test log from: $(whoami)..." >> /tmp/test.log
```

## Environment Variables

### Timezone
This sets timezone for the environment and php. See candidates here: http://php.net/manual/en/timezones.php
```
TZ     # Default: 'Europe/Helsinki'
```

### Development/Production

```
WP_ENV # Default: '' Options: development,testing,production,pretty-much-anything-you-want
```

### Database variables (mysql/mariadb)

```
DB_NAME     # Default: ''
DB_PASSWORD # Default: ''
DB_USER     # Default: ''
DB_HOST     # Default: ''
DB_PORT     # Default: ''
```

Remember to set `DB_NAME`, `DB_PASSWORD` and `DB_USER` and use these variables in your wp-config.php. These are automatically added as envs in php context.

### Email variables

```
SMTP_HOST
```

This variable changes the host where container tries to send mail from. By default this is docker host `172.17.0.1`.

```
SMTP_PORT
```

This variable changes the port where container tries to connect in order to send mail. By default this is `25`.

```
SMTP_TLS
```

If this is provided use username in authenticating to mail server. Default: null
```
SMTP_USER
```

If this is provided use password in authenticating to mail server. Default: null
```
SMTP_PASSWORD
```

If this is `on` mail will use username/password authentication in connections to smtp server.
This will automatically activate if you use `SMTP_USER` and `SMTP_PASSWORD`. Default: `off`
```
SMTP_AUTH
```

See more about these variables in [msmtp docs](http://msmtp.sourceforge.net/doc/msmtp.html#Authentication).

### PHP and Nginx Variables
You can change following env to change php configs:

```
# Variables and default values
PHP_MEMORY_LIMIT=128M
NGINX_MAX_BODY_SIZE=64M
NGINX_FASTCGI_TIMEOUT=30
```

## What's inside container:
### For running WordPress
- php7
- php-fpm7
- nginx
- wp-cli

### For sending emails with smtp server
- msmtp
