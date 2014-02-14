require 'rspec/core/formatters/base_formatter'

class ListFailuresFormatter < RSpec::Core::Formatters::BaseFormatter

  def example_failed(example)
    super
    output.puts RSpec::Core::Metadata::relative_path(example.location)
  end

end
