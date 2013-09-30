require 'spec_helper'

describe "compose_conversation_message_modal example" do

  before do
    view.stub(:current_user).and_return(User.first!)
  end

  it_should_behave_like "a widget example"

end
