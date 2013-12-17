require 'spec_helper'

describe MessageWidget do

  let(:project){ double(:project) }
  let(:conversation){ double(:conversation, project: project) }

  let(:root){ false }
  let(:body) { 'BODY' }
  let(:stripped_body) { 'STRIPPED BODY' }

  let(:message)   {
    double(:message,
      id:            2131,
      shareworthy?:  true,
      knowledge?:    true,
      conversation:  conversation,
      body:          double(:body, html?: false, html_safe?: false, to_s: body),
      stripped_body: double(:stripped_body, html?: false, html_safe?: false, to_s: stripped_body),
      root?:         root,
      creator:       nil,
      from:          'FROM ADDRESS',
      created_at:    Time.now,
      attachments:   double(:attachments, all: [])
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
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        id: "message-2131",
        class: "message custom_class",
        widget: "message",
        shareworthy: true,
        knowledge: true
      }
    end
  end


  context "with a malicious message" do
    let(:body) { '<script>some nefarious crap</script><p>stuff that is okay</p>' }
    let(:stripped_body) { '<html>some nefarious crap</html><p>stuff that is quite alright</p>' }

    it "sanitizes the html using the relaxed configuration" do
      Sanitize.should_receive(:clean).
        with(anything, Sanitize::Config::RELAXED).
        at_least(1).times.
        and_call_original

      rendered_html = presenter.render

      rendered_html.should =~ /okay/
      rendered_html.should =~ /alright/
      rendered_html.should_not =~ /script/
      rendered_html.should_not =~ /html/
    end
  end

  context "with a link in plaintext" do
    let(:body) { 'Go to http://www.rubyonrails.org and say hello to david@loudthinking.com' }
    let(:stripped_body) { 'Go to http://www.rubyonrails.org and say hello to david@loudthinking.com' }

    it "linkifies the plaintext" do
      rendered_html = presenter.render
      html = Nokogiri::HTML.fragment rendered_html
      links = html.css(:a)
      links.count.should == 4
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
