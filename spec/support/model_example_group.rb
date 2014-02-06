module RSpec::Rails::ModelExampleGroup

  include FactoryGirl::Syntax::Methods

  included do
    metadata[:fixtures] = false unless metadata.key? :fixtures
  end

end
