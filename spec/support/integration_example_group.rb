module RSpec::Support::IntegrationExampleGroup

  extend ActiveSupport::Concern

  included do
    metadata[:type] = :integration
    let(:covered){ Covered.new(host: default_url_options[:host], port: default_url_options[:port]) }
    before do
      default_url_options[:host] = Capybara.server_host
      default_url_options[:port] = Capybara.server_port
    end
  end

  delegate :current_user, to: :covered

  def sign_in_as email_address
    covered.current_user_id = find_user_by_email_address(email_address).id
  end

  def as email_address
    sign_in_as email_address
    yield
  ensure
    covered.current_user_id = nil
  end

  module ClassMethods

    def sign_in_as email_address
      before{ sign_in_as email_address }
    end

    def when_not_signed_in &block
      context "when not signed in" do
        before{ sign_out! }
        class_eval(&block)
      end
    end

    def when_signed_in_as email_address, &block
      context "when signed in as #{email_address}" do
        before{ sign_in_as email_address }
        class_eval(&block)
      end
    end

  end

  RSpec.configuration.include self, :type => :integration, :example_group => {
    :file_path => %r{spec[\\/]integration[\\/]}
  }

end
