module RSpec::Support::RequestExampleGroup

  extend ActiveSupport::Concern

  included do
    metadata[:type] = :request
    let(:threadable){ Threadable.new(host: default_url_options[:host], port: default_url_options[:port]) }
    before do
      default_url_options[:host] = Capybara.server_host
      default_url_options[:port] = Capybara.server_port
      integration_session.host = "#{Capybara.server_host}:#{Capybara.server_port}"
    end
  end

  delegate :current_user, to: :threadable

  def sign_in! user, remember_me: false
    post sign_in_path, {
      "authentication" => {
        "email_address" => user.email_address,
        "password"      => "password",
      }
    }
    expect(response).to redirect_to root_url
    threadable.current_user_id = user.id
  end

  def sign_out!
    get sign_out_path
    expect(response).to redirect_to root_url
    threadable.current_user_id = nil
  end

  def sign_in_as email_address
    sign_in! find_user_by_email_address(email_address)
  end

  def response_json
    JSON.parse(response.body)
  end

  module ClassMethods

    def when_not_signed_in &block
      context "when not signed in" do
        before{ sign_out! }
        class_eval(&block)
      end
    end

    def when_signed_in_as email_address, &block
      context "when signed in as #{email_address}" do
        before{ sign_in! threadable.users.find_by_email_address!(email_address) }
        class_eval(&block)
      end
    end

  end

  RSpec.configuration.include self, :example_group => { :file_path => %r{spec[\\/]requests[\\/]} }
end
