require 'spec_helper'

describe "compose_conversation_message_modal example" do

  when_signed_in_as 'alice@ucsd.covered.io' do
    it_should_behave_like "a widget example"
  end

end
