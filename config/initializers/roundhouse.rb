require 'roundhouse'
require 'roundhouse/web'

REDIS_URL = if Rails.env.production?
              'redis://172.31.21.131:6379/14'
            else
              'redis://127.0.0.1:6379/14'
            end


Roundhouse.configure_client do |config|
  config.redis = { namespace: 'roundhouse_sandbox:rh', url: REDIS_URL }
end

Roundhouse.configure_server do |config|
  config.redis = { namespace: 'roundhouse_sandbox:rh', url: REDIS_URL }
end
