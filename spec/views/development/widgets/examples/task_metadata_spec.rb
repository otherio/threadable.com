require 'spec_helper'

describe "task_metadata example" do

  before do
    view.stub(:signed_in?).and_return(true)
    covered.current_user_id = Task.with_doers.first.doers.first.id
    view.stub(:current_user).and_return( covered.current_user )
  end

  it_should_behave_like "a widget example"

end
