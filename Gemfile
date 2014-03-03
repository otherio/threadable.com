source 'https://rubygems.org'

ruby "2.0.0"

gem 'rails', '4.0.0'
gem 'jquery-rails'
gem 'unicorn'
gem 'sinatra'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sidetiq'

gem 'redis'
gem 'pg', '0.17.0'

gem 'bcrypt-ruby', '~> 3.0.0'
gem 'stringex'
gem 'method_object'
gem 'options_hash-method_object'
gem 'js-routes'
gem 'incoming'
gem 'mail'
gem 'encryptor'
gem 'acts_as_list'
gem 'simple_form'
gem 'virtus'
gem 'cancan'

gem 'filepicker-rails'
gem 'sanitize'
gem 'htmlentities'
gem 'fog'
gem 'httmultiparty'
gem 'let'

gem 'haml-rails'
gem 'compass-rails', '~> 1.1.2'
gem 'sass-rails'
gem 'ember-rails'
gem 'emblem-rails'
gem 'ember-source'
gem 'uglifier', '>= 1.0.3'
gem 'animate-sass'
gem 'roadie'
gem 'mixpanel-ruby'

gem 'newrelic_rpm'

gem 'honeybadger'

gem 'thread_safe', :git => 'git://github.com/headius/thread_safe.git', :ref => '177381261d4'

gem 'omniauth'
gem 'omniauth-trello'

group :production, :staging do
  gem 'rails_12factor'
end

group :development do
  gem 'active_record_query_trace'
end

group :development, :test, :staging do
  gem 'pry-rails'
end

group :development, :test do
  gem 'pry-debugger'
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'activerecord-fixture_builder'
  gem 'binding_of_caller'
  gem "mail_view"
  gem 'fuubar'
  gem 'rspec-instafail'
  gem 'jasmine'
  gem 'timecop', require: nil
end

group :test do
  gem 'capybara', '>= 2.0.2'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: nil
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'codeclimate-test-reporter', require: nil
  gem 'ffaker'
  gem 'rest-client'
end
