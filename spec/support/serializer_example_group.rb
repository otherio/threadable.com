module RSpec::Support::SerializerExampleGroup

  extend ActiveSupport::Concern

  def covered
    @covered ||= Covered.new(
      host: Capybara.server_host,
      port: Capybara.server_port,
    )
  end

  included do
    include SerializerConcern
    let(:options){ {} }
    subject{ described_class.serialize(covered, payload, options) }
  end

  def sign_in_as email_address
    covered.current_user_id = find_user_by_email_address(email_address).id
  end

  delegate :current_user, to: :covered

  RSpec.configuration.include self, :type => :serializer, :example_group => {
    :file_path => %r{spec[\\/]serializers[\\/]}
  }

end
