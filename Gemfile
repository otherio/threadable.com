source 'https://rubygems.org'

ruby "2.0.0"

gem 'rails', '4.1.5'
gem 'jquery-rails'
gem 'unicorn'
gem 'sinatra'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sidetiq'
gem 'sidekiq-unique-jobs'

gem 'redis'
gem 'pg'

gem 'bcrypt'
gem 'stringex'
gem 'method_object'
gem 'options_hash-method_object'
gem 'js-routes'
gem 'incoming'
gem 'mail', :git => 'git://github.com/raindrift/mail.git', :ref => 'ccea7228c6456'
gem 'mail_alternatives_with_attachments'
gem 'encryptor'
gem 'acts_as_list'
gem 'simple_form'
gem 'virtus'
gem 'cancan'
gem 'rack-zippy'

gem 'filepicker-rails'
gem 'sanitize'
gem 'htmlentities'
gem 'fog'
gem 'httmultiparty'
gem 'let'

gem 'haml'
gem 'redcarpet'
gem 'compass-rails'
gem 'compass-flexbox'
gem 'sass-rails'
gem 'ember-rails'
gem 'emblem-rails'
gem 'ember-source'
gem 'uglifier'
gem 'animate-sass'
gem 'roadie-rails'
gem 'mixpanel-ruby'

gem 'newrelic_rpm'

gem 'honeybadger'

gem 'omniauth'
gem 'omniauth-trello'
gem 'omniauth-google-oauth2'

gem 'google-api-client'

gem 'algoliasearch-rails'
gem 'dnsruby'

group :production, :staging do
  gem 'rails_12factor'
end

group :development do
  gem 'spring'
  gem 'active_record_query_trace'
  # gem 'ruby-prof'
  # gem 'rack-mini-profiler'
  # gem 'flamegraph'
end

group :development, :test, :staging do
  gem 'pry-rails'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'dotenv-rails'
  gem 'rspec-rails', '3.0.2'
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
  gem 'ffaker'
  gem 'rest-client'
  gem 'rspec-legacy_formatters'
  gem 'webmock', require: nil
end
