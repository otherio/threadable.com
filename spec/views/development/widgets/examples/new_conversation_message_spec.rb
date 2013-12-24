require 'spec_helper'

describe "new_conversation_message example" do

  when_signed_in_as 'alice@ucsd.example.com' do
    it_should_behave_like "a widget example"
  end

end
