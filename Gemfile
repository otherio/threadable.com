source 'https://rubygems.org'

ruby "2.0.0"

gem 'rails', '4.0.0'
gem 'jquery-rails'
gem 'unicorn'
gem 'sinatra'
gem 'sidekiq'
gem 'sidekiq-failures'

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

gem 'filepicker-rails'
gem 'bootstrap-wysihtml5-rails'
gem 'sanitize'
gem 'htmlentities'
gem 'fog'
gem 'httmultiparty'
gem 'let'

gem 'haml-rails'
gem 'compass-rails', '~> 1.1.2'
gem 'sass-rails'
gem 'ember-rails'
gem 'ember-source'
gem 'uglifier', '>= 1.0.3'
gem 'animate-sass'
gem 'roadie'
gem 'mixpanel-ruby'

gem 'newrelic_rpm'
gem 'appsignal'

gem 'honeybadger'

gem 'thread_safe', :git => 'git://github.com/headius/thread_safe.git', :ref => '177381261d4'

group :production, :staging do
  gem 'rails_12factor'
end

group :development do
  gem 'active_record_query_trace'
end

group :development, :test, :staging do
  gem 'pry-rails'
  gem 'pry-debugger'
end

group :development, :test do
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
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: nil
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'minitest', require: nil
  gem 'webmock'
  gem 'rest-client'
end
