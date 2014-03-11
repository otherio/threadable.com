source 'https://rubygems.org'

ruby "2.0.0"

gem 'rails', '4.1.0'
gem 'jquery-rails'
gem 'unicorn'
gem 'sinatra'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sidetiq'

gem 'redis'
gem 'pg'

gem 'bcrypt-ruby'
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
gem 'compass-rails'
gem 'compass-flexbox'
gem 'sass-rails'
gem 'ember-rails'
gem 'emblem-rails'
gem 'ember-source'
gem 'uglifier'
gem 'animate-sass'
gem 'roadie'
gem 'mixpanel-ruby'

gem 'newrelic_rpm'

gem 'honeybadger'

gem 'thread_safe', :git => 'git://github.com/headius/thread_safe.git', :ref => '177381261d4'

gem 'omniauth'
gem 'omniauth-trello'
gem 'ruby-trello', :git => 'git@github.com:otherio/ruby-trello.git', :require => 'trello'

gem 'algoliasearch-rails'
gem 'dnsruby'

gem 'skylight'

group :production, :staging do
  gem 'rails_12factor'
end

group :development do
  gem 'spring'
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
  gem 'rb-readline'  #needed because rbenv and homebrew readline still don't seem to play nice together
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

group :staging_spec do
  gem 'nvlope', '0.0.2'
end
