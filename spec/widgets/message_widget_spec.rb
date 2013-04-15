require 'spec_helper'

describe MessageWidget do

  let(:project){ double(:project) }
  let(:conversation){ double(:conversation, project: project) }
  let(:message)   { double(:message, shareworthy?: true, knowledge?: true, conversation: conversation) }
  let(:arguments) { [message, 0] }

  def html_options
    {class: 'custom_class'}
  end

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        message: message,
        first_message: true,
        index: 0,
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "message custom_class",
        shareworthy: true,
        knowledge: true
      }
    end
  end


  describe "link_to_toggle" do
    it "should..." do
      view.should_receive(:project_conversation_message_path).with(project, conversation, message).and_return('THE_PATH')
      params = {message:{shareworthy: false}}.to_param
      classname = "shareworthy control-link"
      block = proc{}
      view.should_receive(:link_to).with('THE_PATH', remote: true, method: 'put', :"data-params" => params, class: classname, &block).and_return('THE LINK')
      presenter.link_to_toggle(:shareworthy, &block).should == 'THE LINK'
    end
  end

end
