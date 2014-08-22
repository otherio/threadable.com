require 'support/capybara'

module RSpec::Support::LiveExampleGroup

  extend ActiveSupport::Concern

  included do
    metadata[:type] = :live
    before do
      default_url_options[:host] = 'staging.threadable.com'
      default_url_options[:port] = 80
      Capybara.app_host = 'http://staging.threadable.com'
    end
  end

  def sign_in_as email_address, password
    visit '/sign_in'
    fill_in 'Email Address', with: email_address
    fill_in 'Password', with: password
    click_button 'Sign in'
    expect(page).to have_content 'Organizations'
  end

  def as email_address, password
    sign_in_as email_address, password
    yield
  end

  def reload!
    visit current_url
  end

  def send_simple_message to, subject, body
    RestClient.post "https://api:key-0cc-z2i16-2n9x2vr8g7l1i4o3xv-fv6"\
    "@api.mailgun.net/v2/staging.threadable.com/messages",
    :from => "Speccy User <threadable-auto-deploy-sender@mailinator.com>",
    :to => to,
    :subject => subject,
    :text => body
  end

  module ClassMethods

    def sign_in_as email_address, password
      before{ sign_in_as email_address, password }
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

  RSpec.configuration.include self, :type => :live, file_path: %r{spec[\\/]live[\\/]}

end
