module RSpec::Rails::ModelExampleGroup

  include FactoryGirl::Syntax::Methods

  included do
    metadata[:fixtures] = false unless metadata.key? :fixtures
  end

  module ClassMethods

    def when_not_signed_in &block
      let(:current_user){ nil }
      before do
        threadable.stub(
          current_user: nil,
          current_user_id: nil,
        )
      end
    end

    def when_signed_in &block
      let(:current_user){ double :current_user, id: 489 }
      before do
        threadable.stub(
          current_user: current_user,
          current_user_id: current_user.id,
        )
      end
    end

  end

end
