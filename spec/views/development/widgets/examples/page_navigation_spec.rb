require 'spec_helper'

describe "page_navigation example" do

  before do
    view.stub current_user: Covered::User.last!
    view.stub signup_enabled?: true
  end

  it_should_behave_like "a widget example"

end
