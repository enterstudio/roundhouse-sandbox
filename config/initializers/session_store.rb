# Be sure to restart your server when you modify this file.

# See: https://gist.github.com/toolmantim/9597022
# See: https://github.com/rails/rails/issues/15843#issuecomment-125784043

require 'rack/session/abstract/id'
class Rack::Session::Abstract::SessionHash
  private
  def stringify_keys(other)
    hash = {}
    other = other.to_hash unless other.is_a?(Hash) # hack hack hack
    other.each do |key, value|
      hash[key.to_s] = value
    end
    hash
  end
end

Rails.application.config.session_store :cookie_store, key: '_roundhouse-sandbox_session'
