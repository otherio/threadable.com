module RSpec::Support::ViewExampleGroup

  extend ActiveSupport::Concern

  included do
    let(:threadable){ Threadable.new(host: Capybara.server_host) }
    before do
      @view.stub(threadable: threadable)
      def @view.current_user
        threadable.current_user
      end
    end
  end

  delegate :current_user, to: :threadable

  module ClassMethods

    def when_not_signed_in &block
      context "when not signed in" do
        before{ sign_out! }
        class_eval(&block)
      end
    end

    def when_signed_in_as email_address, &block
      context "when signed in as #{email_address}" do
        before{ threadable.current_user_id = find_user_by_email_address(email_address).id }
        class_eval(&block)
      end
    end

  end


  RSpec.configuration.include self, :type => :view


end
