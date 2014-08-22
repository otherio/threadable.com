require 'rspec/core/formatters/documentation_formatter'
require 'rspec/instafail'

class DocumentationInstafail < RSpec::Core::Formatters::DocumentationFormatter
  def example_failed(example)
    super(example)
    # instafail.example_failed(example)
  end

  def instafail
    @instafail ||= ModifiedInstafail.new(output)
  end

  class ModifiedInstafail < RSpec::Instafail

    def dump_backtrace(example)
      exception = example.execution_result[:exception]
      format_backtrace(exception.backtrace, example).each do |backtrace_info|
        path = File.expand_path backtrace_info[%r{(\A.+?):\d}, 1] rescue binding.pry
        if path.start_with?(RAILS_ROOT.to_s)
          output.puts detail_color("#{long_padding}# #{backtrace_info}")
        else
          output.puts default_color("#{long_padding}# #{backtrace_info}")
        end
      end
    end

  end

end
