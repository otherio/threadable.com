source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'haml-rails'
gem 'jquery-rails'
gem 'thin'

gem 'stringex'  # for url slugs
gem 'devise'    # authentication
gem 'virtus'
gem 'method_object'
gem 'rails-widgets', git: 'https://github.com/deadlyicon/rails-widgets'
# gem 'rails-widgets', path: './vendor/gems/rails-widgets'
gem 'pg'
gem 'js-routes'
gem 'resque'
gem 'incoming'
gem 'mail'
gem 'omniauth'
gem 'omniauth-clef'
gem 'encryptor'
gem 'acts_as_list'

group :assets do
  gem 'compass-rails'
  gem 'sass-rails'
  gem 'font-awesome-sass-rails'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'style-guide'
  gem 'rb-fsevent', require: nil
  gem 'debugger'
  gem 'mailcatcher'
  # gem 'sql-logging'
end

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'sqlite3'
  gem 'foreman' # for heroku
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  gem 'pry-rails'
  gem 'pry-debugger'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'capybara', '>= 2.0.2'
  gem 'capybara-webkit'
  gem 'shoulda-matchers'
  gem 'cucumber-rails', require: nil
  gem 'resque_spec'
  gem 'timecop'
  gem 'launchy'
end

# we need this as long as we are goig to load fixtures in prod
group :test, :production do
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'database_cleaner'
  gem 'fixture_builder'
end
