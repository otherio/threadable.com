module CoveredExampleGroup

  extend ActiveSupport::Concern

  included do
    let(:current_user){ nil }
    let(:covered){ Covered.new current_user: current_user, host: host, port: port }
    let(:host){ 'test-covered.io' }
    let(:port){ 80 }
  end

end

RSpec::configure do |c|
  c.include CoveredExampleGroup, :type => :covered, :example_group => {
    :file_path => c.escaped_path(%w[spec covered])
  }
end
