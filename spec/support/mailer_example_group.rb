module RSpec::Support::MailerExampleGroup

  extend ActiveSupport::Concern

  included do
    let(:covered_current_user_record){ nil }
    let(:covered_current_user_id){ covered_current_user_record.try(:id) }
    let(:covered_host){ Capybara.server_host }
    let(:covered_port){ Capybara.server_port }
    delegate :current_user, to: :covered

    before do
      self.default_url_options = {host: covered.host, port: covered.port}
    end
  end

  def covered
    @covered ||= Covered.new(
      host: covered_host,
      port: covered_port,
      current_user_id: covered_current_user_id,
    )
  end


  def extract_project_unsubscribe_token string
    project_unsubscribe_link = URI.extract(string).find{|link| link =~ %r(/unsubscribe/) }
    project_unsubscribe_link or return
    project_unsubscribe_link[%r{/unsubscribe/(.*)},1]
  end

  def extract_project_resubscribe_token string
    project_resubscribe_link = URI.extract(string).find{|link| link =~ %r(/resubscribe/) }
    project_resubscribe_link or return
    project_resubscribe_link[%r{/resubscribe/(.*)},1]
  end

  def extract_user_setup_token string
    user_setup_link = URI.extract(string).find{|link| link =~ %r(/users/setup/) } or return
    user_setup_link or return
    user_setup_link[%r{/users/setup/(.*)},1]
  end



  module ClassMethods

    def signed_in_as email_address=nil, &block
      block_given? || email_address.present? or raise ArgumentErrot
      block ||= ->{ find_user_by_email_address(email_address) } unless block_given?
      let(:covered_current_user_record, &block)
    end

  end

  RSpec.configuration.include self, :type => :mailer

end
