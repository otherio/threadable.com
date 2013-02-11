require 'spec_helper'

describe "message" do

  let(:user){ double(:user, name: 'USER NAME') }

  let(:message){
    double(:message,
     from: 'MESSAGE FROM',
     body: 'MESSAGE BODY',
     user: user,
    )
  }

  def locals
    {message: message}
  end

  describe "return value" do
    subject{ return_value }
    it { should be_a String}
    it { should =~ /From:\s+USER NAME/ }
    it { should include 'MESSAGE BODY' }

    context "when the message has no user" do
      let(:user){ nil }
      it { should =~ /From:\s+MESSAGE FROM/ }
      it { should include 'MESSAGE BODY' }
    end
  end

end
