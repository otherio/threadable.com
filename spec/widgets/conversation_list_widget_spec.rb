require 'spec_helper'

describe ConversationListWidget do

  let(:conversations)          { double(:conversations, not_muted_with_participants: not_muted_conversations, muted_with_participants: muted_conversations) }
  let(:organization)           { double(:organization, conversations: conversations ) }
  let(:not_muted_conversations){ double(:not_muted_conversations) }
  let(:muted_conversations)    { double(:muted_conversations) }
  let(:arguments)              { [organization] }

  def html_options
    {class: 'custom_class'}
  end

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        organization: organization,
        not_muted_conversations: not_muted_conversations,
        muted_conversations: muted_conversations
      }
    end
  end

  describe "html_options" do
    it "should return the expected hash" do
      subject.html_options.should == {
        class: "conversation_list custom_class",
        widget: "conversation_list",
      }
    end
  end

end
