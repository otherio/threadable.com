require 'spec_helper'

describe "tasks_sidebar example" do

  before do
    view.stub(:current_user).and_return( Covered::User.last )
  end

  it_should_behave_like "a widget example"

end
