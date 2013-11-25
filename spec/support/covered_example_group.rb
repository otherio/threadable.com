module RSpec::Support::CoveredExampleGroup

  extend ActiveSupport::Concern

  included do
    metadata[:fixtures] = false
    let(:covered_current_user_record){ nil }
    let(:covered_current_user_id){ covered_current_user_record.try(:id) }
    let(:covered_host){ Capybara.server_host }
    let(:covered_port){ Capybara.server_port }
    let(:covered){ Covered.new(host: covered_host, port: covered_port, current_user_id: covered_current_user_id) }
  end

  delegate :current_user, to: :covered

  RSpec.configuration.include self, :type => :covered, :example_group => {
    :file_path => %r{spec[\\/]models[\\/]covered[\\/]}
  }

  RSpec.configuration.include FactoryGirl::Syntax::Methods, :type => :covered
end
