require 'spec_helper'

describe MessageWidget do

  let(:project){ double(:project) }
  let(:conversation){ double(:conversation, project: project) }

  let(:stripped_plain){ 'STRIPPED PLAIN' }
  let(:body_plain){ 'BODY PLAIN' }
  let(:stripped_html){ 'STRIPPED HTML' }
  let(:body_html){ 'BODY HTML' }

  let(:root){ false }

  let(:message)   {
    double(:message,
      shareworthy?: true,
      knowledge?: true,
      conversation: conversation,
      body_plain: body_plain,
      stripped_plain: stripped_plain,
      body_html: body_html,
      stripped_html: stripped_html,
      root?: root,
    )
  }
  let(:arguments) { [message] }

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
        body_plain: "BODY PLAIN",
        hide_quoted_text: true,
        stripped_plain: "STRIPPED PLAIN",
        body_html: 'BODY HTML',
        stripped_html: 'STRIPPED HTML'
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "message custom_class",
        widget: "message",
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

  describe "hide_quoted_text local" do
    subject{ presenter.locals[:hide_quoted_text] }

    context "when the message is a root message" do
      let(:root){ true }
      it { should be_false }
    end

    context "when the message is not a root message" do
      let(:root){ false }

      context "when the message body is not the same as the message stripped" do
        let(:body_plain){ 'NOT THE SAME!'}
        it { should be_true }
      end

      context "when the message body is the same as the message stripped" do
        let(:body_plain){ stripped_plain }
        it { should be_false }
      end
    end


  end

end
