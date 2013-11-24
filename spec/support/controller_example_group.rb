module RSpec::Support::ControllerExampleGroup

  extend ActiveSupport::Concern

  def covered
    controller.covered
  end

  def current_user
    covered.current_user
  end

  def sign_in! user, remember_me: false
    controller.sign_in! user, remember_me: remember_me
  end

  def sign_out!
    controller.sign_out!
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
        before{ sign_in! covered.users.find_by_email_address!(email_address) }
        class_eval(&block)
      end
    end

  end

  RSpec.configuration.include self, :type => :controller

end
