require 'support/capybara'

module RSpec::Support::FeatureExampleGroup

  extend ActiveSupport::Concern
  include RSpec::Support::Capybara

  included do
    metadata[:driver] = :selenium
    metadata[:fixtures] = true
    metadata[:transaction] = false
    default_url_options[:host] = Capybara.server_host
    default_url_options[:port] = Capybara.server_port
    let(:threadable){ Threadable.new(host: default_url_options[:host], port: default_url_options[:port]) }
  end

  delegate :current_user, to: :threadable

  def reload!
    visit current_url
  end

  def wait_for_ember!
    evaluate_script('ember_is_done = false')
    evaluate_script('Ember.run(function(){ ember_is_done = true })')
    Timeout.timeout(Capybara.default_wait_time) do
      sleep 0.01 until evaluate_script('ember_is_done')
    end
  end

  RSpec.configuration.include self, :type => :feature

end

# look in here for more feature example group methods
Dir[Rails.root + 'spec/support/feature_example_group/*.rb'].each{|p| require p}
