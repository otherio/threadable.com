module RSpec::Support::SerializerExampleGroup

  extend ActiveSupport::Concern

  def covered
    @covered ||= Covered.new(
      host: Capybara.server_host,
      port: Capybara.server_port,
    )
  end

  delegate :current_user, to: :covered

  RSpec.configuration.include self, :type => :serializer, :example_group => {
    :file_path => %r{spec[\\/]serializers[\\/]}
  }

end
