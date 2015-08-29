require 'roundhouse/web'

Rails.application.routes.draw do
  mount Roundhouse::Web => '/admin/roundhouse'
end
