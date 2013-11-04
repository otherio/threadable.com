module MailerExampleGroup

  extend ActiveSupport::Concern

  included do
    let(:current_user){ nil }
    let(:covered){ Covered.new current_user: current_user, host: host, port: port }
    let(:host){ 'test-covered.io' }
    let(:port){ 80 }
    before do
      self.default_url_options = {host: host, port: port}
    end
  end

end

RSpec::configure do |c|
  c.include MailerExampleGroup, :type => :mailer, :example_group => {
    :file_path => c.escaped_path(%w[spec mailers])
  }
end
