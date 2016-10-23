----
-- This file connects into redis and handles errors from redis connection to nginx
----
local redis = require("resty.redis");
local red = redis:new()

-- Get redis configs from ENVs
local config = {}

config[host] = os.getenv("REDIS_HOST")

--cant connect to redis because env is not set
if not config[host] then
    ngx.log(ngx.ERR, "REDIS_HOST is not set. Can't connect to redis: ")
    ngx.exit(500)
end

config[port] = os.getenv("REDIS_PORT")
if not config[port] then
    config[port] = 6379
end

config[password] = os.getenv("REDIS_PASSWORD")

-- Sometimes we want to use different database than the default 0
config[database] = os.getenv("REDIS_DATABASE")

-- Set 5s connection timeout for redis
red:set_timeout(5000)

-- connect to redis
local ok, err = red:connect(config[host], config[port]);
if not ok then
    -- can't connect to redis
    ngx.log(ngx.ERR, "Redis failed to connect: ", err)
    ngx.exit(500)
end

-- authenticate to redis
if not config[password] == "" then
    local res, err = red:auth(config[password])
    if not res then
        ngx.log(ngx.ERR, "Redis failed to authenticate: ", err)
        red:close()
        ngx.exit(500)
    end
end

-- Switch database from default 0 if database is
if not config[database] == "" then
    local ok, err = red:select(db)
    if not ok then
        ngx.log(ngx.ERR, "Redis failed to select database: ", err)
        red:close()
        ngx.exit(500)
    end
end
