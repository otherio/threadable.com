module RSpec::Support::ControllerExampleGroup

  extend ActiveSupport::Concern

  included do
    include SerializerConcern
  end

  def threadable
    controller.threadable
  end

  def current_user
    threadable.current_user
  end

  def sign_in! user, remember_me: false
    controller.sign_in! user, remember_me: remember_me
  end

  def sign_out!
    controller.sign_out!
  end

  def response_json
    JSON.parse(response.body)
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
        before{ sign_in! threadable.users.find_by_email_address!(email_address) }
        class_eval(&block)
      end
    end

  end

  RSpec.configuration.include self, :type => :controller

end
