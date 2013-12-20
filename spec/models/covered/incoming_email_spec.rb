require 'spec_helper'

describe Covered::IncomingEmail do

  let :params do
    create_incoming_email_params(
      from:          'alice@ucsd.covered.io',
      envelope_from: 'alice.neilson@gmail.com',
      sender:        'alice.neilson@gmail.com',
    )
  end
  let(:incoming_email_record){ double(:incoming_email_record, id: 8342, params: params) }
  let(:incoming_email){ described_class.new(covered, incoming_email_record) }
  let(:project){ double(:project, members: double(:members), subject_tag: 'foo') }

  subject{ incoming_email }

  it{ should have_constant :Attachments }
  it{ should have_constant :Bounce }
  it{ should have_constant :Deliver }
  it{ should have_constant :Process }

  it { should delegate(:id        ).to(:incoming_email_record) }
  it { should delegate(:to_param  ).to(:incoming_email_record) }
  it { should delegate(:params    ).to(:incoming_email_record) }
  it { should delegate(:processed?).to(:incoming_email_record) }
  it { should delegate(:bounced?  ).to(:incoming_email_record) }
  it { should delegate(:held?     ).to(:incoming_email_record) }
  it { should delegate(:created_at).to(:incoming_email_record) }
  it { should delegate(:errors    ).to(:incoming_email_record) }
  it { should delegate(:persisted?).to(:incoming_email_record) }


  describe 'initialize' do
    it 'takes covered and incoming_email_record and assigns them to instance variables' do
      covered = double(:covered)
      incoming_email_record = double(:incoming_email_record)
      instance = described_class.new(covered, incoming_email_record)
      expect(instance.covered).to be covered
      expect(instance.incoming_email_record).to be incoming_email_record
    end
  end

  describe 'processed!' do
    it 'sets processed to true and saves the record' do
      expect(incoming_email_record).to receive(:processed=).with(true)
      expect(incoming_email_record).to receive(:save!)
      incoming_email.processed!
    end
  end

  describe 'bounced!' do
    it 'sets bounced to true and saves the record' do
      expect(incoming_email_record).to receive(:bounced=).with(true)
      expect(incoming_email_record).to receive(:save!)
      incoming_email.bounced!
    end
  end

  describe 'process!' do
    context 'when processed? returns false' do
      before{ expect(incoming_email).to receive(:processed?).and_return(false)}
      it 'runs the Process method object on its self' do
        expect(described_class::Process).to receive(:call).with(incoming_email)
        incoming_email.process!
      end
    end
    context 'when processed? returns true' do
      before{ expect(incoming_email).to receive(:processed?).and_return(true)}
      it 'does not run the Process method object on its self' do
        expect(described_class::Process).to_not receive(:call)
        incoming_email.process!
      end
    end
  end

  describe 'deliver!' do
    context 'when delivered? returns false' do
      before{ expect(incoming_email).to receive(:delivered?).and_return(false)}
      it 'runs the Deliver method object on its self' do
        expect(described_class::Deliver).to receive(:call).with(incoming_email)
        incoming_email.deliver!
      end
    end
    context 'when delivered? returns true' do
      before{ expect(incoming_email).to receive(:delivered?).and_return(true)}
      it 'does not run the Deliver method object on its self' do
        expect(described_class::Deliver).to_not receive(:call)
        incoming_email.deliver!
      end
    end
  end

  describe 'hold!' do
    context 'when held? returns false' do
      before{ expect(incoming_email).to receive(:held?).and_return(false)}
      it 'runs the Hold method object on its self' do
        expect(covered.emails).to receive(:send_email).with(:message_held_notice, incoming_email)
        expect(incoming_email).to receive(:held!)
        incoming_email.hold!
      end
    end
    context 'when held? returns true' do
      before{ expect(incoming_email).to receive(:held?).and_return(true)}
      it 'does not run the Hold method object on its self' do
        expect(covered.emails).to_not receive(:send_email)
        expect(incoming_email).to_not receive(:held!)
        incoming_email.hold!
      end
    end
  end

  describe 'bounce!' do
    context 'when bounced? returns false' do
      before{ expect(incoming_email).to receive(:bounced?).and_return(false)}
      it 'runs the Bounce method object on its self' do
        expect(described_class::Bounce).to receive(:call).with(incoming_email)
        incoming_email.bounce!
      end
    end
    context 'when bounced? returns true' do
      before{ expect(incoming_email).to receive(:bounced?).and_return(true)}
      it 'does not run the Bounce method object on its self' do
        expect(described_class::Bounce).to_not receive(:call)
        incoming_email.bounce!
      end
    end
  end



  describe 'creator_is_a_project_member?' do
    subject{ incoming_email.creator_is_a_project_member? }
    context 'when project is nil' do
      before{ expect(incoming_email).to receive(:project).and_return(nil) }
      it { should be_false }
    end
    context 'when project is not nil' do
      let(:project){ double(:project, members: double(:members)) }
      before{ expect(incoming_email).to receive(:project).at_least(1).times.and_return(project) }
      context 'when creator is nil' do
        before{ expect(incoming_email).to receive(:creator).and_return(nil) }
        it { should be_false }
      end
      context 'when creator is not nil' do
        let(:creator){ double(:creator) }
        before{ expect(incoming_email).to receive(:creator).at_least(1).times.and_return(creator) }
        context 'when project.members.include?(creator) returns true' do
          before{ expect(project.members).to receive(:include?).with(creator).and_return(true) }
          it { should be_true }
        end
        context 'when project.members.include?(creator) returns false' do
          before{ expect(project.members).to receive(:include?).with(creator).and_return(false) }
          it { should be_false }
        end
      end
    end
  end

  describe 'delivered?' do
    subject{ incoming_email.delivered? }

    context 'when processed? returns false' do
      before{ expect(incoming_email).to receive(:processed?).and_return(false) }
      it { should be_false }
    end

    context 'when processed? returns true' do
      before{ expect(incoming_email).to receive(:processed?).and_return(true) }

      context 'when held? returns true' do
        before{ expect(incoming_email).to receive(:held?).and_return(true) }
        it { should be_false }
      end

      context 'when held? returns false' do
        before{ expect(incoming_email).to receive(:held?).and_return(false) }

        context 'when bounced? returns true' do
          before{ expect(incoming_email).to receive(:bounced?).and_return(true) }
          it { should be_false }
        end

        context 'when bounced? returns false' do
          before{ expect(incoming_email).to receive(:bounced?).and_return(false) }

          context 'when a message is present' do
            before{ expect(incoming_email).to receive(:message).and_return(nil) }
            it { should be_false }
          end

          context 'when a message is not present' do
            before{ expect(incoming_email).to receive(:message).and_return('6') }
            it { should be_true }
          end
        end
      end
    end
  end

  describe 'bounceable?' do
    subject{ incoming_email.bounceable? }
    context 'when project is nil' do
      before{ expect(incoming_email).to receive(:project).and_return(nil) }
      it { should be_true }
    end
    context 'when project is not nil' do
      before{ expect(incoming_email).to receive(:project).and_return(project) }

      context 'when the subject is valid' do
        before { expect(incoming_email).to receive(:subject_valid?).and_return(true) }
        it { should be_false }
      end

      context 'when the subject is invalid' do
        before { expect(incoming_email).to receive(:subject_valid?).and_return(false) }
        it { should be_true }
      end
    end
  end

  describe 'holdable?' do
    subject{ incoming_email.holdable? }

    context 'when bounceable? is true' do
      before{ expect(incoming_email).to receive(:bounceable?).and_return(true) }
      it { should be_false }
    end
    context 'when bounceable? is false' do
      before{ expect(incoming_email).to receive(:bounceable?).and_return(false) }

      context 'when parent_message is present' do
        before{ expect(incoming_email).to receive(:parent_message).and_return(34543) }
        it { should be_false }
      end
      context 'when parent_message is nil' do
        before{ expect(incoming_email).to receive(:parent_message).and_return(nil) }
        context 'when creator is not a member of the project' do
          before{ expect(incoming_email).to receive(:creator_is_a_project_member?).and_return(false) }
          it { should be_true }
        end
      end
    end
  end

  describe 'deliverable?' do
    subject{ incoming_email.deliverable? }
    context 'when bounceable? is true' do
      before{ expect(incoming_email).to receive(:bounceable?).and_return(true) }
      it { should be_false }
    end
    context 'when bounceable? is false' do
      before{ expect(incoming_email).to receive(:bounceable?).and_return(false) }
      context 'when holdable? is true' do
        before{ expect(incoming_email).to receive(:holdable?).and_return(true) }
        it { should be_false }
      end
      context 'when holdable? is false' do
        before{ expect(incoming_email).to receive(:holdable?).and_return(false) }
        it { should be_true }
      end
    end
  end

  describe '#subject_valid?' do
    let(:subject_line) { '[task] i am a subject line' }
    let(:body) { 'a message body' }

    subject{ incoming_email.subject_valid? }

    before do
      incoming_email.stub(:subject).and_return(subject_line)
      incoming_email.stub(:stripped_plain).and_return(body)
      incoming_email.stub(:project).and_return(double(:project, subject_tag: 'subject-tag'))
    end

    it { should be_true }

    context 'with a subject containing only things that are stripped' do
      let(:subject_line) { '[task][subject-tag] '}
      context 'with a plaintext body' do
        let(:body) { "I've got a lovely bunch of coconuts, here they are standing in a row" }
        it { should be_true }
      end

      context 'with a plaintext body containing no words' do
        let(:body) { ' ' }
        it { should be_false }
      end
    end

    context 'with a blank subject line and a blank body' do
      let(:subject_line) { '' }
      let(:body) { '' }

      it { should be_false }
    end
  end



  its(:subject)                { should eq params['subject'] }
  its(:message_id)             { should eq params['Message-Id'] }
  its(:from)                   { should eq params['from'] }
  its(:envelope_from)          { should eq params['X-Envelope-From'] }
  its(:sender)                 { should eq params['sender'] }
  its(:recipient)              { should eq params['recipient'] }
  its(:to)                     { should eq params['To'] }
  its(:cc)                     { should eq params['Cc'] }
  its(:content_type)           { should eq params['Content-Type'] }
  its(:date)                   { should eq Time.parse(params['Date']).in_time_zone }
  its(:in_reply_to)            { should eq params['In-Reply-To'] }
  its(:references)             { should eq params['References'] }
  its(:message_headers)        { should eq JSON.parse(params['message-headers']) }
  its(:message_headers_as_hash){ should eq Hash[JSON.parse(params['message-headers'])] }
  its(:body_html)              { should eq params['body-html'] }
  its(:body_plain)             { should eq params['body-plain'] }
  its(:stripped_html)          { should eq params['stripped-html'] }
  its(:stripped_plain)         { should eq params['stripped-text'] }

  its(:from_email_addresses){ should eq ['alice@ucsd.covered.io', 'alice.neilson@gmail.com'] }


  describe 'find_project!' do
    # these are integration tested
  end
  describe 'find_message!' do
    # these are integration tested
  end
  describe 'find_creator!' do
    # these are integration tested
  end
  describe 'find_parent_message!' do
    # these are integration tested
  end
  describe 'find_conversation!' do
    # these are integration tested
  end
  describe 'creator_is_a_project_member?' do
    # these are integration tested
  end



  describe 'attachments' do
    it 'returns a Attachments.new(self)' do
      expect(incoming_email.attachments).to be_a described_class::Attachments
      expect(incoming_email.attachments).to be incoming_email.attachments
      expect(incoming_email.attachments.covered).to be covered
      expect(incoming_email.attachments.incoming_email).to be incoming_email
    end
  end

  describe 'project=' do
    context 'when given a Covered::Project' do
      it 'sets @project to the given project and set incoming_email_record.project to project.project_record' do
        project_record = double(:project_record)
        project = double(:project, project_record: project_record)
        expect(incoming_email_record).to receive(:project=).with(project_record)
        expect(incoming_email_record).to receive(:project).and_return(project_record)
        incoming_email.project = project
        expect(incoming_email.project).to eq project
      end
    end
    context 'when given nil' do
      it 'sets @project and incoming_email_record.project to nil' do
        expect(incoming_email_record).to receive(:project=).with(nil)
        expect(incoming_email_record).to receive(:project).and_return(nil)
        incoming_email.project = nil
        expect(incoming_email.project).to be_nil
      end
    end
  end

  describe 'project' do
    context 'when incoming_email_record.project is nil' do
      before{ expect(incoming_email_record).to receive(:project).and_return(nil) }
      it 'returns nil' do
        expect(incoming_email.project).to be_nil
      end
    end
    context 'when incoming_email_record.project is present' do
      let(:project_record){ double :project_record }
      before{ expect(incoming_email_record).to receive(:project).at_least(1).times.and_return(project_record) }
      it 'returns a Covered::Project' do
        expect(incoming_email.project).to be_a Covered::Project
        expect(incoming_email.project).to be incoming_email.project
        expect(incoming_email.project.project_record).to be project_record
      end
    end
  end

  describe 'message=' do
    context 'when given a Covered::Message' do
      it 'sets @message to the given message and set incoming_email_record.message to message.message_record' do
        message_record = double(:message_record)
        creator        = double(:creator)
        conversation   = double(:conversation)
        parent_message = double(:parent_message)

        message = double(:message,
          message_record: message_record,
          creator: creator,
          conversation: conversation,
          parent_message: parent_message,
        )

        expect(incoming_email_record).to receive(:message=).with(message_record)
        expect(incoming_email_record).to receive(:message).and_return(message_record)
        expect(incoming_email).to receive(:creator=).with(creator)
        expect(incoming_email).to receive(:conversation=).with(conversation)
        expect(incoming_email).to receive(:parent_message=).with(parent_message)
        incoming_email.message = message
        expect(incoming_email.message).to eq message
      end
    end
    context 'when given nil' do
      it 'sets @message and incoming_email_record.message to nil' do
        expect(incoming_email_record).to receive(:message=).with(nil)
        expect(incoming_email_record).to receive(:message).and_return(nil)
        incoming_email.message = nil
        expect(incoming_email.message).to be_nil
      end
    end
  end

  describe 'message' do
    context 'when incoming_email_record.message is nil' do
      before{ expect(incoming_email_record).to receive(:message).and_return(nil) }
      it 'returns nil' do
        expect(incoming_email.message).to be_nil
      end
    end
    context 'when incoming_email_record.message is present' do
      let(:message_record){ double :message_record, id: 231232 }
      before{ expect(incoming_email_record).to receive(:message).at_least(1).times.and_return(message_record) }
      it 'returns a Covered::Message' do
        expect(incoming_email.message).to be_a Covered::Message
        expect(incoming_email.message).to be incoming_email.message
        expect(incoming_email.message.message_record).to be message_record
      end
    end
  end

  describe 'creator=' do
    context 'when given a Covered::User' do
      it 'sets @creator to the given creator and set incoming_email_record.creator to creator.user_record' do
        user_record = double(:user_record)
        creator = double(:creator, user_record: user_record)
        expect(incoming_email_record).to receive(:creator=).with(user_record)
        expect(incoming_email_record).to receive(:creator).and_return(user_record)
        incoming_email.creator = creator
        expect(incoming_email.creator).to eq creator
      end
    end
    context 'when given nil' do
      it 'sets @project and incoming_email_record.project to nil' do
        expect(incoming_email_record).to receive(:creator=).with(nil)
        expect(incoming_email_record).to receive(:creator).and_return(nil)
        incoming_email.creator = nil
        expect(incoming_email.creator).to be_nil
      end
    end
  end

  describe 'creator' do
    context 'when incoming_email_record.creator is nil' do
      before{ expect(incoming_email_record).to receive(:creator).and_return(nil) }
      it 'returns nil' do
        expect(incoming_email.creator).to be_nil
      end
    end
    context 'when incoming_email_record.creator is present' do
      let(:user_record){ double :user_record, id: 231232 }
      before{ expect(incoming_email_record).to receive(:creator).at_least(1).times.and_return(user_record) }
      it 'returns a Covered::User' do
        expect(incoming_email.creator).to be_a Covered::User
        expect(incoming_email.creator).to be incoming_email.creator
        expect(incoming_email.creator.user_record).to be user_record
      end
    end
  end

  describe 'parent_message=' do
    context 'when given a Covered::Message' do
      let(:message_record){ double(:message_record) }
      let(:conversation){ double :conversation }
      let(:parent_message){ double(:parent_message, message_record: message_record, conversation: conversation) }

      context 'when incoming_email.conversation is nil' do
        before do
          incoming_email.stub(conversation: nil)
        end
        it 'sets @parent_message to the given parent_message and sets incoming_email_record.parent_message to parent_message.message_record and sets self.conversation to parent_message.conversation' do
          expect(incoming_email_record).to receive(:parent_message=).with(message_record)
          expect(incoming_email_record).to receive(:parent_message).and_return(message_record)
          expect(incoming_email).to receive(:conversation=).with(conversation)
          incoming_email.parent_message = parent_message
          expect(incoming_email.parent_message).to eq parent_message
        end
      end

      context 'when the given parent message\'s conversation does match the incoming email conversation' do
        before do
          incoming_email.stub(conversation: conversation)
        end
        it 'sets @parent_message to the given parent_message and sets incoming_email_record.parent_message to parent_message.message_record' do
          expect(incoming_email_record).to receive(:parent_message=).with(message_record)
          expect(incoming_email_record).to receive(:parent_message).and_return(message_record)
          incoming_email.parent_message = parent_message
          expect(incoming_email).to_not receive(:conversation=)
          expect(incoming_email.parent_message).to eq parent_message
        end
      end

      context 'when the given parent message\'s conversation does not match the incoming email conversation' do
        let(:other_conversation){ double(:other_conversation) }
        before do
          incoming_email.stub(:conversation).and_return(other_conversation)
        end
        it 'raises and ArgumentError' do
          expect{ incoming_email.parent_message = parent_message }.to raise_error(ArgumentError, 'invalid parent message. Conversations are not the same')
        end
      end
    end
    context 'when given nil' do
      it 'sets @parent_message and incoming_email_record.parent_message to nil' do
        expect(incoming_email_record).to receive(:parent_message=).with(nil)
        expect(incoming_email_record).to receive(:parent_message).and_return(nil)
        incoming_email.parent_message = nil
        expect(incoming_email.parent_message).to be_nil
      end
    end
  end

  describe 'parent_message' do
    context 'when incoming_email_record.parent_message is nil' do
      before{ expect(incoming_email_record).to receive(:parent_message).and_return(nil) }
      it 'returns nil' do
        expect(incoming_email.parent_message).to be_nil
      end
    end
    context 'when incoming_email_record.parent_message is present' do
      let(:message_record){ double :message_record, id: 231232 }
      before{ expect(incoming_email_record).to receive(:parent_message).at_least(1).times.and_return(message_record) }
      it 'returns a Covered::Message' do
        expect(incoming_email.parent_message).to be_a Covered::Message
        expect(incoming_email.parent_message).to be incoming_email.parent_message
        expect(incoming_email.parent_message.message_record).to be message_record
      end
    end
  end

  describe 'conversation=' do
    context 'when given a Covered::Conversation' do
      it 'sets @conversation to the given conversation and set incoming_email_record.conversation to conversation.user_record' do
        conversation_record = double(:conversation_record)
        conversation = double(:conversation, conversation_record: conversation_record)
        expect(incoming_email_record).to receive(:conversation=).with(conversation_record)
        expect(incoming_email_record).to receive(:conversation).and_return(conversation_record)
        incoming_email.conversation = conversation
        expect(incoming_email.conversation).to eq conversation
      end
    end
    context 'when given nil' do
      it 'sets @project and incoming_email_record.project to nil' do
        expect(incoming_email_record).to receive(:creator=).with(nil)
        expect(incoming_email_record).to receive(:creator).and_return(nil)
        incoming_email.creator = nil
        expect(incoming_email.creator).to be_nil
      end
    end
  end

  describe 'conversation' do
    context 'when incoming_email_record.conversation is nil' do
      before{ expect(incoming_email_record).to receive(:conversation).and_return(nil) }
      it 'returns nil' do
        expect(incoming_email.conversation).to be_nil
      end
    end
    context 'when incoming_email_record.conversation is present' do
      let(:conversation_record){ double :conversation_record, id: 231232, task?: false }
      before{ expect(incoming_email_record).to receive(:conversation).at_least(1).times.and_return(conversation_record) }
      it 'returns a Covered::Conversation' do
        expect(incoming_email.conversation).to be_a Covered::Conversation
        expect(incoming_email.conversation).to be incoming_email.conversation
        expect(incoming_email.conversation.conversation_record).to be conversation_record
      end
    end
  end

  it { should delegate(:header    ).to(:mail_message) }
  it { should delegate(:multipart?).to(:mail_message) }

  describe 'mail_message' do
    it 'returns a MailMessage' do
      mail_message = incoming_email.mail_message
      expect(mail_message).to be_a Mail::Message
      expect(mail_message).to be incoming_email.mail_message
      expect(mail_message.sender).to eq params['sender']
      expect(mail_message.from  ).to eq [params['From']]
    end
  end

  context do
    let :incoming_email_record do
      double(:incoming_email_record,
        id:              4589,
        params:          params,
        processed?:      true,
        bounced?:        false,
        held?:           false,
        creator_id:      12,
        project_id:      13,
        conversation_id: 14,
        message_id:      15,
      )
    end
    before{ expect(incoming_email).to receive(:delivered?).and_return(true) }
    its(:inspect){ should eq %(#<Covered::IncomingEmail id: 4589, processed: true, bounced: false, held: false, delivered: true, from: "alice@ucsd.covered.io", creator_id: 12, project_id: 13, conversation_id: 14, message_id: 15>) }
  end

end
