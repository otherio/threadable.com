require 'spec_helper'

describe "message" do

  let(:user){
    double(:user,
      name: 'USER NAME',
      avatar_url: 'USER AVATAR URL',
    )
  }

  let(:message){
    double(:message,
     from: 'MESSAGE FROM',
     body: 'MESSAGE BODY',
     user: user,
     created_at: 'MESSAGE CREATED AT',
    )
  }

  let(:presenter){ double(:presenter) }

  def locals
    {
      message: message,
      presenter: presenter,
    }
  end

  before do
    view.should_receive(:timeago).with(message.created_at)
    presenter.should_receive(:link_to_toggle).with(:shareworthy)
    presenter.should_receive(:link_to_toggle).with(:knowledge)
  end

  it "should render the message with the user's info" do
    return_value.should be_a String
    return_value.should include 'USER NAME'
    return_value.should include 'MESSAGE BODY'
  end

  context "when the message has no user" do
    let(:user){ nil }
    it "should render the message with the message's from info" do
      return_value.should be_a String
      return_value.should include 'MESSAGE FROM'
      return_value.should include 'MESSAGE BODY'
    end
  end

end
