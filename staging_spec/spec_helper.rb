ENV["RAILS_ENV"] ||= 'test'

Bundler.require :staging_spec

require 'capybara/rspec'
require 'pry'
require 'active_support/all'


RAILS_ROOT   = Pathname.new File.expand_path('../../', __FILE__)
LOGGER = ActiveSupport::Logger.new(RAILS_ROOT+"log/#{ENV["RAILS_ENV"]}.log")
require RAILS_ROOT + 'spec/support/capybara'
require RAILS_ROOT + 'spec/support/be_at_url_matcher'
require RAILS_ROOT + 'spec/support/be_at_path_matcher'

Pathname.new(File.expand_path('../support', __FILE__)).children.each do |path|
  require path
end

Capybara.app_host = 'http://threadablestaging.com'

RSpec.configure do |config|
  config.order = "random"

  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
  config.include RSpec::Support::Capybara

  config.before do
    # resize_window_to(:large)
  end
end
