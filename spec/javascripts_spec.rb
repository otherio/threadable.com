require 'spec_helper'

describe 'javascript specs', :type => :request do

  it "should all pass" do
    visit javascript_tests_path
    sleep 0.25 until results.present?
    expect(results['passed']).to be_true
  end

  def results
    @results ||= page.evaluate_script 'jasmine.results'
  end

end
