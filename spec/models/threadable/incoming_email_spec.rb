require 'spec_helper'

describe Threadable::IncomingEmail do

  let :params do
    create_incoming_email_params(
      from:          'alice@ucsd.example.com',
      envelope_from: 'alice.neilson@gmail.com',
      sender:        'alice.neilson@gmail.com',
    )
  end

  let(:creator) { double(:creator, id: 1234) }

  let(:incoming_email_record){ double(:incoming_email_record, id: 8342, params: params, groups: [], organization: organization, creator: creator) }
  let(:incoming_email){ described_class.new(threadable, incoming_email_record) }
  let(:organization){ double(:organization, members: double(:members, find_by_user_id: member), subject_tag: 'foo', hold_all_messages?: false) }
  let(:member) { double(:member, role: :member)}
  let(:owner) { double(:owner, role: :owner)}

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
    it 'takes threadable and incoming_email_record and assigns them to instance variables' do
      threadable = double(:threadable)
      incoming_email_record = double(:incoming_email_record)
      instance = described_class.new(threadable, incoming_email_record)
      expect(instance.threadable).to be threadable
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

  describe 'dropped!' do
    it 'sets processed to true but does not send email or create a message' do
      expect(incoming_email_record).to receive(:processed=).with(true)
      expect(incoming_email_record).to receive(:save!)
      incoming_email.dropped!
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
    context 'when held? returns true' do
      before{ expect(incoming_email).to receive(:held?).and_return(true)}
      it 'does not run the Hold method object on its self' do
        expect(threadable.emails).to_not receive(:send_email)
        expect(incoming_email).to_not receive(:held!)
        incoming_email.hold!
      end
    end
    context 'when held? returns false' do
      before do
        expect(incoming_email).to receive(:held?).and_return(false)
        incoming_email.stub_chain(:organization, :members, :who_are_owners).and_return [owner]
      end

      it 'sends out the held message notice and marks its self as held' do
        incoming_email.stub_chain(:organization, :hold_all_messages?).and_return false
        expect(threadable.emails).to receive(:send_email).with(:message_held_notice, incoming_email)
        expect(threadable.emails).to receive(:send_email).with(:message_held_owner_notice, incoming_email, owner)
        expect(incoming_email).to receive(:held!)
        incoming_email.hold!
      end
      context 'when the organization holds all messages' do
        it 'just marks its self as held' do
          incoming_email.stub_chain(:organization, :hold_all_messages?).and_return true
          expect(threadable.emails).to_not receive(:send_email).with(:message_held_notice, anything)
          expect(threadable.emails).to receive(:send_email).with(:message_held_owner_notice, incoming_email, owner)
          expect(incoming_email).to receive(:held!)
          incoming_email.hold!
        end
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

  describe 'drop!' do
    context 'when dropped? returns false' do
      before{ expect(incoming_email).to receive(:dropped?).and_return(false)}
      it 'runs the drop method object on its self' do
        expect(incoming_email_record).to receive(:processed=).with(true)
        expect(incoming_email_record).to receive(:save!)
        incoming_email.drop!
      end
    end
    context 'when dropped? returns true' do
      before{ expect(incoming_email).to receive(:dropped?).and_return(true)}
      it 'does not run the drop method object on its self' do
        expect(incoming_email_record).to_not receive(:processed=).with(true)
        incoming_email.drop!
      end
    end
  end

  describe 'creator_is_an_organization_member?' do
    subject{ incoming_email.creator_is_an_organization_member? }
    context 'when organization is nil' do
      before{ expect(incoming_email).to receive(:organization).and_return(nil) }
      it { should be_false }
    end
    context 'when organization is not nil' do
      let(:organization){ double(:organization, members: double(:members)) }
      before{ expect(incoming_email).to receive(:organization).at_least(1).times.and_return(organization) }
      context 'when creator is nil' do
        before{ expect(incoming_email).to receive(:creator).and_return(nil) }
        it { should be_false }
      end
      context 'when creator is not nil' do
        let(:creator){ double(:creator) }
        before{ expect(incoming_email).to receive(:creator).at_least(1).times.and_return(creator) }
        context 'when organization.members.include?(creator) returns true' do
          before{ expect(organization.members).to receive(:include?).with(creator).and_return(true) }
          it { should be_true }
        end
        context 'when organization.members.include?(creator) returns false' do
          before{ expect(organization.members).to receive(:include?).with(creator).and_return(false) }
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

  describe 'dropped?' do
    subject{ incoming_email.dropped? }

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
            it { should be_true }
          end

          context 'when a message is not present' do
            before{ expect(incoming_email).to receive(:message).and_return('6') }
            it { should be_false }
          end
        end
      end
    end
  end


  describe 'bounceable?' do
    subject{ incoming_email.bounceable? }
    context 'when organization is nil' do
      before{ expect(incoming_email).to receive(:organization).and_return(nil) }
      it { should be_true }
    end
    context 'when organization is not nil' do
      before{ expect(incoming_email).to receive(:organization).and_return(organization) }

      context 'when the subject is valid' do
        before { expect(incoming_email).to receive(:subject_valid?).and_return(true) }

        context 'when the groups are valid' do
          before { expect(incoming_email).to receive(:groups_valid?).and_return(true) }
          it { should be_false }
        end

        context 'when the groups are invalid' do
          before { expect(incoming_email).to receive(:groups_valid?).and_return(false) }
          it { should be_true }
        end
      end

      context 'when the subject is invalid' do
        before { expect(incoming_email).to receive(:subject_valid?).and_return(false) }
        it { should be_true }
      end
    end
  end

  describe 'holdable?' do
    subject{ incoming_email.holdable? }

    before{ incoming_email.stub(:organization).and_return(organization) }

    context 'when the organization holds all messages' do
      before do
        organization.stub :hold_all_messages? => true
        expect(incoming_email).to receive(:creator_is_an_organization_member?).and_return(false)
      end

      context 'when a parent message is not present' do
        before{ expect(incoming_email).to receive(:parent_message).and_return(nil) }

        it { should be_true }
      end

      context 'when a parent message is present' do
        let(:group){ double :group, :hold_messages? => false }

        before do
          expect(incoming_email).to receive(:parent_message).and_return(5235)
          expect(incoming_email).to receive(:groups).and_return([group])
        end

        it { should be_false }
      end
    end

    context 'when the organization does not hold all messages' do
      before{ organization.stub :hold_all_messages? => false }

      context 'when is at least one group that does not hold messages' do
        let(:group){ double :group, :hold_messages? => false }
        before{ expect(incoming_email).to receive(:groups).and_return([group]) }
        it { should be_false }
      end

      context 'when there are no groups that do not hold messages' do
        before{ expect(incoming_email).to receive(:groups).and_return([]) }

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

            context 'when creator is not a member of the organization' do
              before{ expect(incoming_email).to receive(:creator_is_an_organization_member?).and_return(false) }
              it { should be_true }
            end

          end

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
        context 'when droppable? is false' do
          before{ expect(incoming_email).to receive(:droppable?).and_return(false) }
          it { should be_true }
        end
        context 'when droppable? is true' do
          before{ expect(incoming_email).to receive(:droppable?).and_return(true) }
          it { should be_false }
        end
      end
    end
  end

  describe 'droppable?' do
    subject{ incoming_email.droppable? }

    context 'when there is a parent message' do
      before{ expect(incoming_email).to receive(:parent_message).and_return(34543) }

      context 'and it contains only commands and whitespace' do
        before { expect(incoming_email).to receive(:body_has_content?).and_return(false) }

        it { should be_true }
      end

      context 'and it has non-command content' do
        before { expect(incoming_email).to receive(:body_has_content?).and_return(true) }

        it { should be_false }
      end
    end

    context 'when there is no parent message' do
      before{ expect(incoming_email).to receive(:parent_message).and_return(nil) }

      it { should be_false }
    end
  end

  describe '#subject_valid?' do
    let(:subject_line) { '[task] i am a subject line' }
    let(:body) { 'a message body' }

    subject{ incoming_email.subject_valid? }

    before do
      incoming_email.stub(:subject).and_return(subject_line)
      incoming_email.stub(:stripped_plain).and_return(body)
      incoming_email.stub(:organization).and_return(double(:organization, subject_tag: 'subject-tag', groups: double(:groups, all: [])))
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

  describe '#groups_valid?' do
    let(:groups) do
      [
        double(:group1, email_address_tag: 'group1'),
        double(:group2, email_address_tag: 'group2')
      ]
    end
    let(:email_address_tags) { ['group2', 'group1'] }

    before do
      incoming_email.stub groups: groups, email_address_tags: email_address_tags
    end

    subject{ incoming_email.groups_valid? }
    it {should be_true}

    context 'with an extra email address tag' do
      let(:email_address_tags) { ['group1', 'group2', 'eeevil'] }
      it {should be_true}
    end

    # not sure how this would ever happen
    context 'missing an email address tag' do
      let(:email_address_tags) { ['group1'] }
      it {should be_false}
    end
  end

  describe '#body_has_content?' do
    subject{ incoming_email.body_has_content? }

    before do
      incoming_email.stub(:stripped_plain).and_return(body)
    end

    context 'with a blank body' do
      let(:body) { '' }
      it { should be_false }
    end

    context 'with a body that contains only commands and random whitespace' do
      let(:body) { '&add Maria Rivera\n\n \n' }
      it { should be_false }
    end

    context 'with a body that contains commands and threadable tips' do
      let(:body){
        %(&done\n)
      }
      it { should be_false }
    end

    context 'with a body that contains commands and real live text' do
      let(:body){
        %(&done\n\n Hello Seattle, I am a mountaineer, in the hills and highlands. I fall asleep in hospital parking lots.)
      }
      it { should be_true }
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

  its(:from_email_addresses){ should eq ['alice@ucsd.example.com', 'alice.neilson@gmail.com'] }


  describe 'find_organization!' do
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
  describe 'creator_is_an_organization_member?' do
    # these are integration tested
  end
  describe 'find_groups!' do
    # these are integration tested
  end

  describe '#email_address_tags' do
    subject{ incoming_email.email_address_tags }
    before{ expect(incoming_email).to receive(:recipient).and_return(recipient) }
    context 'when the email address is foo@threadable.com' do
      let(:recipient){ 'foo@threadable.com' }
      it{ should eq [] }
    end
    context 'when the email address is groupy+bar@org.threadable.com' do
      let(:recipient){ 'groupy+bar@org.threadable.com' }
      it{ should eq ['groupy'] }
    end
    context 'when the email address is groupy@org.threadable.com' do
      let(:recipient){ 'groupy@org.threadable.com' }
      it{ should eq ['groupy'] }
    end
    context 'when the email address is groupy@org.threadable.com' do
      let(:recipient){ 'groupy+task@org.threadable.com' }
      it{ should eq ['groupy'] }
    end
    context 'when the email address contains many tags' do
      let(:recipient){ 'foo+bar+baz@threadable.com' }
      it{ should eq ['bar', 'baz'] }
    end
    context 'when the email address contains +task' do
      let(:recipient){ 'foo+bar+task@threadable.com' }
      it{ should eq ['bar'] }
    end
  end


  describe 'attachments' do
    it 'returns a Attachments.new(self)' do
      expect(incoming_email.attachments).to be_a described_class::Attachments
      expect(incoming_email.attachments).to be incoming_email.attachments
      expect(incoming_email.attachments.threadable).to be threadable
      expect(incoming_email.attachments.incoming_email).to be incoming_email
    end
  end

  describe 'organization=' do
    context 'when given a Threadable::Organization' do
      it 'sets @organization to the given organization and set incoming_email_record.organization to organization.organization_record' do
        organization_record = double(:organization_record)
        organization = double(:organization, organization_record: organization_record)
        expect(incoming_email_record).to receive(:organization=).with(organization_record)
        expect(incoming_email_record).to receive(:organization).and_return(organization_record)
        incoming_email.organization = organization
        expect(incoming_email.organization).to eq organization
      end
    end
    context 'when given nil' do
      it 'sets @organization and incoming_email_record.organization to nil' do
        expect(incoming_email_record).to receive(:organization=).with(nil)
        expect(incoming_email_record).to receive(:organization).and_return(nil)
        incoming_email.organization = nil
        expect(incoming_email.organization).to be_nil
      end
    end
  end

  describe 'organization' do
    context 'when incoming_email_record.organization is nil' do
      before{ expect(incoming_email_record).to receive(:organization).and_return(nil) }
      it 'returns nil' do
        expect(incoming_email.organization).to be_nil
      end
    end
    context 'when incoming_email_record.organization is present' do
      let(:organization_record){ double :organization_record }
      before{ expect(incoming_email_record).to receive(:organization).at_least(1).times.and_return(organization_record) }
      it 'returns a Threadable::Organization' do
        expect(incoming_email.organization).to be_a Threadable::Organization
        expect(incoming_email.organization).to be incoming_email.organization
        expect(incoming_email.organization.organization_record).to be organization_record
      end
    end
  end

  describe 'message=' do
    context 'when given a Threadable::Message' do
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
      it 'returns a Threadable::Message' do
        expect(incoming_email.message).to be_a Threadable::Message
        expect(incoming_email.message).to be incoming_email.message
        expect(incoming_email.message.message_record).to be message_record
      end
    end
  end

  describe 'creator=' do
    context 'when given a Threadable::User' do
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
      it 'sets @organization and incoming_email_record.organization to nil' do
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
      it 'returns a Threadable::User' do
        expect(incoming_email.creator).to be_a Threadable::User
        expect(incoming_email.creator).to be incoming_email.creator
        expect(incoming_email.creator.user_record).to be user_record
      end
    end
  end

  describe 'parent_message=' do
    context 'when given a Threadable::Message' do
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
      it 'returns a Threadable::Message' do
        expect(incoming_email.parent_message).to be_a Threadable::Message
        expect(incoming_email.parent_message).to be incoming_email.parent_message
        expect(incoming_email.parent_message.message_record).to be message_record
      end
    end
  end

  describe 'conversation=' do
    context 'when given a Threadable::Conversation' do
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
      it 'sets @organization and incoming_email_record.organization to nil' do
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
      it 'returns a Threadable::Conversation' do
        expect(incoming_email.conversation).to be_a Threadable::Conversation
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
        organization_id:      13,
        conversation_id: 14,
        message_id:      15,
      )
    end
    before{ expect(incoming_email).to receive(:delivered?).and_return(true) }
    its(:inspect){ should eq %(#<Threadable::IncomingEmail id: 4589, processed: true, bounced: false, held: false, delivered: true, from: "alice@ucsd.example.com", creator_id: 12, organization_id: 13, conversation_id: 14, message_id: 15>) }
  end

end
