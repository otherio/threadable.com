require 'spec_helper'

describe Message do
  let(:message){ Message.where(subject: 'layup body carbon').last! }
  subject{ message }

  it { should belong_to(:parent_message) }
  it { should belong_to(:conversation) }

  it "has a message id with a predictable domain (not some heroku crap hostname)" do
    subject.message_id_header.should =~ /^<.+\@localhost>$/
  end

  context "with a parent message" do
    let(:parent_message) { message.parent_message } #create(:message, references_header: '<more-message-ids@foo.com>') }

    it "inherits references from it parent message, and adds the parent's message id to references" do
      message.save
      expect(parent_message.references_header).to be_present
      expect(parent_message.message_id_header).to be_present
      message.references_header.should == [parent_message.references_header, parent_message.message_id_header].join(' ')
    end
  end

  describe "#unique_id" do
    it "returns the message_id_header url safe base 64 encoded" do
      message = subject
      message.message_id_header = '<foo_bar_baz@example.com>'
      message.unique_id.should == Base64.urlsafe_encode64(message.message_id_header)
    end
  end

  describe "#body_html_as_text" do
    it 'returns the body html as plaintext' do
      subject.body_html_as_text.should == "This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of them before they went in. Bethany got epoxy everywhere! It was pretty funny. Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass like you suggested, since we're under weight on the wheels anyway. Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass like you suggested, since we're under weight on the wheels anyway."
    end
  end

end
