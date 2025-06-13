require "redis"

redis_config = {
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

$redis = Redis.new(redis_config)

Rails.application.config.cache_store = :redis_cache_store, {
  redis: $redis,
  expires_in: 1.hour,
  namespace: "todo_api:#{Rails.env}"
}
