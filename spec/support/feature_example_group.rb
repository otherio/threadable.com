require 'support/capybara'

module RSpec::Support::FeatureExampleGroup

  extend ActiveSupport::Concern

  included do
    metadata[:fixtures] = true
    metadata[:transaction] = false
    default_url_options[:host] = Capybara.server_host
    default_url_options[:port] = Capybara.server_port
    let(:covered){ Covered.new(host: default_url_options[:host], port: default_url_options[:port]) }
  end

  delegate :current_user, to: :covered

  def reload!
    visit current_url
  end

  RSpec.configuration.include self, :type => :feature

end

# look in here for more feature example group methods
Dir[Rails.root + 'spec/support/feature_example_group/*.rb'].each{|p| require p}
