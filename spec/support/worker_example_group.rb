module RSpec::Support::WorkerExampleGroup

  extend ActiveSupport::Concern

  included do
    metadata[:fixtures] = false
    let(:threadable_current_user_record){ nil }
    let(:threadable_current_user_id){ threadable_current_user_record.try(:id) }
    let(:threadable_host){ Capybara.server_host }
    let(:threadable_port){ Capybara.server_port }
    let(:threadable){ Threadable.new(host: threadable_host, port: threadable_port, current_user_id: threadable_current_user_id) }
  end

  delegate :current_user, to: :threadable

  RSpec.configuration.include self, :type => :worker, :example_group => {
    :file_path => %r{spec[\\/]workers[\\/]}
  }

end
