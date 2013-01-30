source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'haml-rails'
gem 'jquery-rails'
gem 'thin'

gem 'stringex'  # for url slugs
gem 'devise'    # authentication
gem 'virtus'
#gem 'redis-rails'

group :production do
  gem 'pg'
end

group :assets do
  gem 'sass-rails'
  gem 'compass-rails'
  gem 'font-awesome-sass-rails'
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'debugger'
  gem 'sqlite3'
  gem 'foreman' # for heroku
end

group :test do
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'cucumber-rails', require: nil
  gem 'database_cleaner'
end
