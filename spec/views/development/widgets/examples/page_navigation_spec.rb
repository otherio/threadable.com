require 'spec_helper'

describe "page_navigation example" do

  before do
    view.stub signup_enabled?: true
  end

  when_signed_in_as 'alice@ucsd.covered.io' do
    it_should_behave_like "a widget example"
  end

end
