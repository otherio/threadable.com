require 'spec_helper'

describe MuteConversationLinkWidget do

  let(:organization){ double(:organization, to_param: 'frogfrier') }
  let(:conversation){ double(:conversation, to_param: 'we-need-more-oil', organization: organization, muted?: muted) }
  let(:muted){ false }
  let(:arguments)   { [conversation] }
  let(:node_type){ :a }

  def html_options
    {class: 'custom_class'}
  end

  it_should_behave_like "a widget presenter"

  describe "locals" do
    subject{ presenter.locals }

    context 'when the conversation is muted' do
      let(:muted){ true }
      it do
        should == {
          block: nil,
          presenter: presenter,
          conversation: conversation,
          content: 'un-mute conversation',
        }
      end
    end

    context 'when the conversation is not muted' do
      let(:muted){ false }
      it do
        should == {
          block: nil,
          presenter: presenter,
          conversation: conversation,
          content: 'mute conversation',
        }
      end
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "control-link custom_class mute_conversation_link text-info",
        widget: "mute_conversation_link",
        :"data-method" => "POST",
        href: "/frogfrier/conversations/we-need-more-oil/mute",
      }
    end
  end

end
