require 'spec_helper'

describe "conversation_messages example" do

  when_signed_in_as 'alice@ucsd.example.com' do
    it_should_behave_like "a widget example"
  end

end
