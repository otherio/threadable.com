source 'https://rubygems.org'

ruby "2.0.0"

gem 'rails', '4.0.0'
gem 'haml-rails'
gem 'jquery-rails'
gem 'unicorn'
gem 'sinatra'
gem 'sidekiq'
gem 'sidekiq-failures'

gem 'redis'
gem 'pg'

gem 'bcrypt-ruby', '~> 3.0.0'
gem 'stringex'
gem 'method_object'
gem 'options_hash-method_object'
gem 'rails-widgets', git: 'https://github.com/deadlyicon/rails-widgets'
gem 'js-routes'
gem 'incoming', '0.1.4'
gem 'mail'
gem 'encryptor'
gem 'acts_as_list'
gem 'simple_form'
gem 'virtus'

gem 'filepicker-rails'
gem 'bootstrap-wysihtml5-rails'
gem 'sanitize'
gem 'htmlentities'
gem 'fog', '1.12.1'
gem 'httmultiparty'
gem 'rails_autolink'
gem 'let'

gem "compass-rails", "~> 2.0.alpha.0"
gem 'sass-rails'
gem 'font-awesome-sass-rails'
gem 'uglifier', '>= 1.0.3'
gem 'animate-sass'
gem 'roadie'
gem 'mixpanel-ruby'

gem 'newrelic_rpm'
gem 'appsignal'
gem 'oboe-heroku'

group :production, :staging do
  gem 'rails_12factor'
end

group :production do
  gem 'honeybadger'
end

group :development do
  gem 'meta_request'
  gem 'active_record_query_trace'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'debugger'
  gem 'rspec-rails'
  gem 'pry-rails'
  gem 'pry-debugger'
  gem 'activerecord-fixture_builder'
  gem 'binding_of_caller'
  gem 'better_errors'
  gem "mail_view"
  gem 'fuubar'
end

group :test do
  gem 'capybara', '>= 2.0.2'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'codeclimate-test-reporter', require: nil
  gem 'minitest', require: nil
  gem 'webmock'
  gem 'simplecov'
end
