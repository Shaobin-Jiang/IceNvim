local status, user_config = pcall(require, "user-config")

if not status then
    return require "default"
else
    return user_config
end