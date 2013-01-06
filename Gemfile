source 'https://rubygems.org'

gem 'rails', '3.2.9'

gem 'thin'
gem 'haml-rails'
gem 'database_cleaner'
gem 'stringex'  # for url slugs
gem 'devise'
gem 'jquery-rails'
gem 'rspec-rails'
gem 'tilt'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'font-awesome-sass-rails'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'pg'
end

group :development, :test do
  gem 'debugger'
  gem 'sqlite3'
  gem 'foreman'
end

group :test do
  gem 'nyan-cat-formatter'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'cucumber-rails'
end
