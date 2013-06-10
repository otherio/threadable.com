require 'spec_helper'

describe EmailProcessor do

  let!(:original_conversation_count){ Conversation.count }
  let!(:original_message_count){ Message.count }
  let!(:original_attachment_count){ Attachment.count }
  let(:attachments){
    attachment = Struct.new(:original_filename, :read)
    [
      attachment.new('dogs.jpeg', 'THIS IS SOME FAKE DATA'),
      attachment.new('cats.gif', 'THIS IS SOME OTHER FAKE DATA'),
    ]
  }
  let(:project){ Project.find_by_name("UCSD Electric Racing") }
  let(:sender){ User.find_by_email!('alice@ucsd.multifyapp.com') }
  let(:in_reply_to_header){ nil }
  let(:recipient_param){ 'UCSD Electric Racing <ucsd-electric-racing@multifyapp.com>' }
  let(:from_param){ 'Alice Neilson <alice@ucsd.multifyapp.com>' }

  def message_headers
    {'Message-Id' => '<3j4hjk35hk4h32423k@hackers.io>', 'In-Reply-To' => in_reply_to_header}
  end

  # http://documentation.mailgun.net/user_manual.html#parsed-messages-parameters
  def params
    {
      'signature'        => 'THIS IS A FAKE SIGNATURE THAT WE STUB AROUND',
      'token'            => 'kashfjkhdjksahdjksadhjkasdhkjlashdjklashdjksa',
      'timestamp'        => 1370817404,
      'message-headers'  => message_headers.to_a.to_json,
      'from'             => from_param,
      'recipient'        => recipient_param,
      'subject'          => 'this is the subject',
      'body-html'        => <<-HTML,
<div dir=3D"ltr">I am writing you back. Back! I write!</div>
<div class=3D"g=\nmail_extra">
  <br><br>
  <div class=3D"gmail_quote">
    On Tue, Apr 2, 2013 at 10:51=\n AM, Nicole Aptekar <span dir=3D"ltr">&lt;<a href=3D"mailto:nicoletbn@gmail=\n.com" target=3D"_blank">nicoletbn@gmail.com</a>&gt;</span> wrote:<br>
    <blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
    x #ccc solid;padding-left:1ex">
    <div dir=3D"ltr">Sure~</div>
    <div class=3D"HO=
      EnZb">
      <div class=3D"h5">
        <div class=3D"gmail_extra">
          <br><br>
          <div class=3D"gm=
            ail_quote">
            On Tue, Apr 2, 2013 at 10:37 AM, ian <span dir=3D"ltr">&lt;<a href=3D"mailt=
              o:ian@sonic.net" target=3D"_blank">ian@sonic.net</a>&gt;</span> wrote:<br>
            <blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
            x #ccc solid;padding-left:1ex">It&#39;s Tuesday. I have work lunch Wednesda=
            y, so I can take care of that thing. Also, want to grab food at 12:30?<span=
            >
            <font color=3D"#888888">
              <div>
                <br>
              </div>
              <div>-Ian<span></span></div>
            </font>
            </span></blockquote>
          </div>
          <br>
        </div>
      </div>
    </div>
    </blockquote>
  </div>
  <br>
</div>
HTML
      'body-plain'       => <<-TEXT,
"Sorry I sent that blank mail. Shouldn't be possible in the future. derp.


On Sun, Apr 21, 2013 at 5:58 PM, Ian Baker <ian@sonic.net> wrote:

> This is a response!
>
> So there!
>
> On Sunday, April 21, 2013, Nicole Aptekar wrote:
>
> > Another test. Mail back plz?
> > _____
> > View on Multify:
> > http://beta.multifyapp.com/multify-testing/conversations/testing
> > Unsubscribe:
> >
> http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0z_f2O7M6K6eqPdf94=
> >
> >
> _____
> View on Multify:
> http://beta.multifyapp.com/multify-testing/conversations/testing
> Unsubscribe:
> http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0qqfzWrYOzqJ6Pdf90=
>
TEXT
      'stripped-html'    => '<div dir=3D"ltr">I am writing you back. Back! I write!</div>',
      'stripped-text'    => 'I am writing you back. Back! I write!',
      'attachment-count' => attachments.length,
      'attachment-1'     => attachments[0],
      'attachment-2'     => attachments[1],
    }
  end


  # Helpers

  def call!
    @message = EmailProcessor.call(params)
  end

  def filter_token(body)
    EmailProcessor::UnsubscribeTokenFilterer.call(body)
  end


  # Setups

  def self.in_reply_to_a_known_conversation!
    let(:conversation){ project.conversations.where(subject: 'layup body carbon').first! }
    let(:parent_message){ conversation.messages.first! }
    let(:in_reply_to_header){ parent_message.message_id_header }
  end

  def self.in_reply_to_an_unknown_conversation!
    let(:conversation){ nil }
    let(:parent_message){ nil }
    let(:in_reply_to_header){ '<somefakeunknowbsmessageidheader@multifyapp.com>' }
  end


  # Shoulds

  def self.it_should_create_a_message!
    it "should create a message" do
      call!
      expect(Message.count   ).to eq original_message_count + 1
      expect(Attachment.count).to eq original_attachment_count + 2
      validate_message!
    end
  end

  def self.it_should_not_create_a_message!
    it "should not create a message" do
      call!
      expect(Message.count   ).to eq original_message_count
      expect(Attachment.count).to eq original_attachment_count
    end
  end

  def self.it_should_create_a_conversation!
    let(:conversation){ nil }
    let(:expected_conversation_subject){ params['subject'] }
    let(:expected_conversation_creator){ sender }
    it "should create a conversation" do
      call!
      expect(Conversation.count).to eq original_conversation_count + 1
      validate_conversation!
    end
  end

  def self.it_should_not_create_a_conversation!
    let(:expected_conversation_subject){ conversation.subject }
    let(:expected_conversation_creator){ conversation.creator }
    it "should not create a conversation" do
      call!
      expect(Conversation.count).to eq original_conversation_count
    end
  end


  # Validations

  def validate_message!
    assert_queued SendConversationMessageWorker, [{message_id: @message.id}]

    expect(@message.message_id_header).to     eq message_headers['Message-Id']
    expect(@message.subject).to               eq params['subject']
    expect(@message.parent_message).to        eq expected_parent_message
    expect(@message.user).to                  eq expected_sender
    expect(@message.from).to                  eq expected_sender_email
    expect(@message.body_plain).to            eq filter_token(params['body-plain'])
    expect(@message.body_html).to             eq filter_token(params['body-html'])
    expect(@message.stripped_plain).to        eq filter_token(params['stripped-text'])
    expect(@message.stripped_html).to         eq filter_token(params['stripped-html'])
    expect(@message.conversation).to          be_present
    expect(@message.conversation.project).to  eq project

    attachment_data = @message.attachments.map{|a| [a.filename, a.content] }.to_set
    expected_attachment_data = attachments.map{|a| [a.original_filename, a.read]}.to_set
    expect(attachment_data).to eq(expected_attachment_data)
  end

  def validate_conversation!
    expect(@message.conversation.subject).to eq expected_conversation_subject
    expect(@message.conversation.creator).to eq expected_conversation_creator
    expect(@message.conversation.project).to eq project
  end


  # Tests

  let(:expected_parent_message){ parent_message }
  let(:expected_sender){ sender }
  let(:expected_sender_email){ sender.email }

  context "when the message is sent to a known project" do
    context "and the message is not a reply" do
      let(:parent_message){ nil }
      it_should_create_a_message!
      it_should_create_a_conversation!
    end

    context "and the message is a reply" do
      context "to an unknown conversation" do
        in_reply_to_an_unknown_conversation!
        it_should_create_a_message!
        it_should_create_a_conversation!
      end

      context "to an known conversation" do
        in_reply_to_a_known_conversation!
        it_should_create_a_message!
        it_should_not_create_a_conversation!
      end

      context "to a message of another project" do
        let(:other_project){ Project.find_by_name("Mars Exploration Rover") }
        let(:parent_message){ other_project.conversations.first!.messages.first! }
        let(:expected_parent_message){ nil }
        let(:in_reply_to_header){ parent_message.message_id_header }
        it_should_create_a_message!
        it_should_create_a_conversation!
      end

    end
  end

  context "when the message is sent to a unknown project" do
    let(:recipient_param){ 'Unknown Project <some-bullshit-email-address@multifyapp.com>' }
    it_should_not_create_a_message!
    it_should_not_create_a_conversation!
  end

  context "when the message is sent by an unknown user" do
    let(:from_param){ 'Random Person <whoknows@example.com>' }
    context "in reply to a known conversation" do
      let(:expected_sender){ nil }
      let(:expected_sender_email){ 'whoknows@example.com' }
      in_reply_to_a_known_conversation!
      it_should_create_a_message!
      it_should_not_create_a_conversation!
    end
    context "in reply to a unknown conversation" do
      in_reply_to_an_unknown_conversation!
      it_should_not_create_a_message!
      it_should_not_create_a_conversation!
    end
  end

end
