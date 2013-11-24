module RSpec::Support::ViewExampleGroup

  extend ActiveSupport::Concern

  included do
    let(:covered){ Covered.new(host: Capybara.server_host) }
    before do
      @view.stub(covered: covered)
      def @view.current_user
        covered.current_user
      end
    end
  end

  delegate :current_user, to: :covered

  module ClassMethods

    def when_not_signed_in &block
      context "when not signed in" do
        before{ sign_out! }
        class_eval(&block)
      end
    end

    def when_signed_in_as email_address, &block
      context "when signed in as #{email_address}" do
        before{ covered.current_user_id = find_user_by_email_address(email_address).id }
        class_eval(&block)
      end
    end

  end


  RSpec.configuration.include self, :type => :view


end
