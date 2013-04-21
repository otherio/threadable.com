require 'spec_helper'

describe "task_metadata example" do

  before do
    view.stub(:signed_in?).and_return(true)
    view.stub(:current_user).and_return(Task.with_doers.first.doers.first)
  end

  it_should_behave_like "a widget example"

end
