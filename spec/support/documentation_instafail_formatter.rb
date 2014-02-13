require 'rspec/core/formatters/documentation_formatter'
require 'rspec/instafail'

class DocumentationInstafail < RSpec::Core::Formatters::DocumentationFormatter
  def example_failed(example)
    super(example)
    instafail.example_failed(example)
  end

  def instafail
    @instafail ||= RSpec::Instafail.new(output)
  end
end
