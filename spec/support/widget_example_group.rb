module RSpec::Support::WidgetExampleGroup

  extend ActiveSupport::Concern

  included do
    metadata[:fixtures] = false
  end

  RSpec.configure do |config|
    config.include self, example_group: { file_path: %r{spec[\\/]widgets[\\/]} }
    config.include self, example_group: { file_path: %r{rails[\\/]widgets[\\/]rspec} }
  end


end
