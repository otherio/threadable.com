module RSpec::Support::MailerExampleGroup

  extend ActiveSupport::Concern

  included do
    let(:threadable_current_user_record){ nil }
    let(:threadable_current_user_id){ threadable_current_user_record.try(:id) }
    let(:threadable_host){ Capybara.server_host }
    let(:threadable_port){ Capybara.server_port }
    delegate :current_user, to: :threadable

    before do
      self.default_url_options = {host: threadable.host, port: threadable.port}
    end
  end

  def threadable
    @threadable ||= Threadable.new(
      host: threadable_host,
      port: threadable_port,
      current_user_id: threadable_current_user_id,
    )
  end


  def extract_organization_unsubscribe_token string
    organization_unsubscribe_link = URI.extract(string).find{|link| link =~ %r(/unsubscribe/) }
    organization_unsubscribe_link or return
    organization_unsubscribe_link[%r{/unsubscribe/(.*)},1]
  end

  def extract_organization_resubscribe_token string
    organization_resubscribe_link = URI.extract(string).find{|link| link =~ %r(/resubscribe/) }
    organization_resubscribe_link or return
    organization_resubscribe_link[%r{/resubscribe/(.*)},1]
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
      let(:threadable_current_user_record, &block)
    end

  end

  RSpec.configuration.include self, :type => :mailer

end
