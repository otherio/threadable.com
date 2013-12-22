require 'spec_helper'

describe ComposeConversationMessageModalWidget do

  let(:organization)   { double(:organization, conversations: conversations) }
  let(:conversations){ double(:conversations) }
  let(:conversation){ double(:conversation) }
  let(:arguments) { [organization] }

  before do
    conversations.stub(:build).and_return(conversation)
  end

  def html_options
    {class: 'custom_class'}
  end

  it_should_behave_like "a widget presenter"

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        organization: organization,
        conversation: conversation,
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "compose_conversation_message_modal modal hide fade custom_class",
        widget: "compose_conversation_message_modal",
      }
    end
  end

end
