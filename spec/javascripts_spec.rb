require 'spec_helper'

describe 'javascript specs', type: :request do

  it "should all pass" do
    visit javascript_tests_path
    Timeout::timeout(20) do
      until results.present?
        raise page.evaluate_script('document.body.innerHTML') if page.text.include? 'ERROR: '
        sleep 0.25
      end
    end

    unless results['passed']
      specs = specs_for(results).reject{|spec| spec["passed"] }
      failures = specs.map{ |spec| "  "+ spec["description"] }.join("\n")
      raise "The following Javascript specs failed:\n#{failures}\n\n#{page.text}"
    end
  end

  def results
    @results ||= page.evaluate_script 'jasmine.results' rescue nil
  end

  def specs_for(suite)
    specs = suite["specs"] || []
    suite["suites"].each do |suite|
      specs += specs_for(suite)
    end
    specs.each do |spec|
      spec["description"] = %{#{suite["description"]} #{spec["description"]}}
    end
    return specs
  end

end
