-- Load Redis instance with system envs
local red = require("lib/redis").connect(ngx);

-- ngx.var.cache_key
-- Get the redis result from cache
local cache_result, err = red:get( ngx.var.escaped_cache_key )

ngx.log(ngx.STDERR, "cache store key:" .. ngx.var.escaped_cache_key)
-- Close redis connection
red:close()

-- With empty result
if cache_result == "" then
    ngx.say("Error")
    ngx.exit(404)
else
    ngx.say(cache_result)
    ngx.exit(200)
end
