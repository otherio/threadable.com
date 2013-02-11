require 'spec_helper'

describe ConversationMetadataWidget do

  let(:conversation) { double(:conversation) }

  def html_options
    {class: 'custom_class', conversation: conversation}
  end

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
        class: "conversation_metadata custom_class",
      }
    end
  end

end
