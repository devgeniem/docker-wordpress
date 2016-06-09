# Development version
This is development version with xdebug enabled and opcache disabled

## Using
```
$ docker pull devgeniem/wordpress-server:development
$ docker run -it --rm devgeniem/wordpress-server:development -d
```

## Options
If you want to use xdebug in remote you can set your ip address in `XDEBUG_REMOTE_HOST`.
```
XDEBUG_REMOTE_HOST # Default: ''
```
