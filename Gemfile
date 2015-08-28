source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use postgresql as the database for Active Record
gem 'pg'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

#gem 'roundhouse-x', require: 'roundhouse'
gem 'roundhouse-x', require: 'roundhouse', path: '../roundhouse'
gem 'rlet', '~> 0.7.0'

# Shopify API gem
gem 'activeresource', git: 'git://github.com/Shopify/activeresource'
gem 'shopify_app'
gem 'shopify-kaminari'
gem 'awesome_print', require: 'ap'

# Fake data generator for Shopify
#gem 'shopify_faker', git: 'git://github.com/shopappsio/shopify_faker.git'
gem 'shopify_faker', path: '../gems/shopify_faker'
gem 'fabrication'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

