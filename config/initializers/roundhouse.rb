require 'roundhouse'
require 'roundhouse/web'

REDIS_URL = ENV['ROUNDHOUSE_SANDBOX_REDIS_URL'] || 'redis://127.0.0.1:6379/14'

Roundhouse.configure_client do |config|
  config.redis = { namespace: 'roundhouse_sandbox:rh', url: REDIS_URL }
end

Roundhouse.configure_server do |config|
  config.redis = { namespace: 'roundhouse_sandbox:rh', url: REDIS_URL }
end
