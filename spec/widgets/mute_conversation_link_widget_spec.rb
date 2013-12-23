require 'spec_helper'

describe MuteConversationLinkWidget do

  let(:conversation){ double(:conversation) }
  let(:arguments)   { [conversation] }

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
        conversation: conversation,
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "mute_conversation_link custom_class",
        widget: "mute_conversation_link",
      }
    end
  end

end
