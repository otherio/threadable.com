require 'spec_helper'

describe "message" do

  let(:creator){
    double(:creator,
      name: 'USER NAME',
      avatar_url: 'USER AVATAR URL',
    )
  }

  let(:body         ){ double(:body,          html?: false, html_safe?: false, empty?: false, to_s: "BODY") }
  let(:stripped_body){ double(:stripped_body, html?: false, html_safe?: false, empty?: false, to_s: "STRIPPED BODY") }

  let(:message){
    double(:message,
     from:          'MESSAGE FROM',
     creator:       creator,
     created_at:    'MESSAGE CREATED AT',
     body:          body,
     stripped_body: stripped_body,
     attachments:   double(:attachments, all:[]),
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
    return_value.should include 'STRIPPED BODY'
  end

  context "when the message has no creator" do
    let(:creator){ nil }
    it "should render the message with the message's from info" do
      return_value.should include 'MESSAGE FROM'
      return_value.should include 'STRIPPED BODY'
    end
  end

  context "when the message has a stripped body" do
    context "that is html" do
      let(:body         ){ double(:body,          html?: true, html_safe?: true, empty?: false, to_s: "BODY") }
      let(:stripped_body){ double(:stripped_body, html?: true, html_safe?: true, empty?: false, to_s: "STRIPPED BODY") }
      it "should render both the body and the stripped body as html" do
        expect(html.css('.message-text.html'     ).first.text).to eq "STRIPPED BODY"
        expect(html.css('.message-text-full.html').first.text).to eq "BODY"
      end
    end

    context "that is not html" do
      let(:body         ){ double(:body,          html?: false, html_safe?: false, empty?: false, to_s: "BODY") }
      let(:stripped_body){ double(:stripped_body, html?: false, html_safe?: false, empty?: false, to_s: "STRIPPED BODY") }
      it "should render both the body and the stripped body as plain text" do
        expect(html.css('.message-text.plain'     ).first.text).to eq "STRIPPED BODY"
        expect(html.css('.message-text-full.plain').first.text).to eq "BODY"
      end
    end
  end

  context "when the message has no stripped body" do
    let(:stripped_body){ nil }
    context "that is html" do
      let(:body){ double(:body, html?: true, html_safe?: true, empty?: false, to_s: "BODY") }
      it "should render both the body and the stripped body as html" do
        expect(html.css('.message-text.html'       ).first.text).to eq "BODY"
        expect(html.css('.message-text-full.plain')).to be_empty
      end
    end

    context "that is not html" do
      let(:body){ double(:body, html?: false, html_safe?: false, empty?: false, to_s: "BODY") }
      it "should render both the body and the stripped body as plain text" do
        expect(html.css('.message-text.plain'     ).first.text).to eq "BODY"
        expect(html.css('.message-text-full.plain')).to be_empty
      end
    end
  end

  context "when the message body is plain with urls" do
    let(:stripped_body){ nil }
    let(:body){ double(:body, html?: false, html_safe?: false, empty?: false, to_s: "go to http://www.google.com ok?") }
    it "should render those urls as links" do
      expect( html.css('a[href="http://www.google.com"]') ).to be_present
    end
  end

end
