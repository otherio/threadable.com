source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'haml-rails'
gem 'jquery-rails'
gem 'thin'

gem 'stringex'  # for url slugs
gem 'devise'    # authentication
gem 'virtus'
gem 'method_object'
#gem 'redis-rails'
gem 'pg'
gem 'pg_search'

group :production do
end

group :assets do
  gem 'sass-rails'
  gem 'compass-rails'
  gem 'font-awesome-sass-rails'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'style-guide'
  gem 'rb-fsevent', require: nil
end

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'debugger'
  gem 'sqlite3'
  gem 'foreman' # for heroku
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  gem 'pry-rails'
end

group :test do
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'cucumber-rails', require: nil
  gem 'database_cleaner'
  gem 'capybara-webkit'
  gem 'fixture_builder'
end
