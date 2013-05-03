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
     user: user,
     created_at: 'MESSAGE CREATED AT',
     html?: has_html
    )
  }

  let(:presenter){ double(:presenter) }

  let(:hide_quoted_text){ false }
  let(:stripped_html) { nil }
  let(:body_html) { nil }
  let(:has_html) { false }

  def locals
    {
      message: message,
      presenter: presenter,
      stripped_plain: 'STRIPPED PLAIN',
      body_plain: 'BODY PLAIN',
      stripped_html: stripped_html,
      body_html: body_html,
      hide_quoted_text: hide_quoted_text,
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
    return_value.should include 'STRIPPED PLAIN'
  end

  context "when the message has no user" do
    let(:user){ nil }
    it "should render the message with the message's from info" do
      return_value.should include 'MESSAGE FROM'
      return_value.should include 'STRIPPED PLAIN'
    end
  end

  context "when the message does not have quoted text" do
    it "should not render the truncated and full message contents and the show quoted text button" do
      html.css('.message-text-full').should_not be_present
      html.css('button.show-quoted-text').should_not be_present
    end
  end

  context "when the message has quoted text" do
    let(:hide_quoted_text){ true }
    it "should render the truncated and full message contents and the show quoted text button" do
      html.css('.message-text-full').should be_present
      html.css('button.show-quoted-text').should be_present
    end
  end

  context "with no html part" do
    context "when the message does not have quoted text" do
      it "should show the plain message with quoted text removed" do
        html.css('.message-text').text.should == 'STRIPPED PLAIN'
      end
    end

    context "when the message has quoted text" do
      let(:hide_quoted_text){ true }
      it "should show the complete plain message" do
        html.css('.message-text-full').text.should == 'BODY PLAIN'
      end
    end
  end

  context "with an html part" do
    let(:stripped_html) { 'STRIPPED HTML' }
    let(:body_html) { 'BODY HTML' }
    let(:has_html) { true }

    context "when the message does not have quoted text" do
      it "should show the html message with quoted text removed" do
        html.css('.message-text').text.should == 'STRIPPED HTML'
      end
    end

    context "when the message has quoted text" do
      let(:hide_quoted_text){ true }
      it "should show the complete html message" do
        html.css('.message-text-full').text.should == 'BODY HTML'
      end
    end
  end

end
