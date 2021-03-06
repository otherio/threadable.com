require 'spec_helper'

describe Threadable::IncomingEmail, :type => :model do

  let :params do
    create_incoming_email_params(
      from:          'alice@ucsd.example.com',
      envelope_from: 'alice.neilson@gmail.com',
      sender:        'alice.neilson@gmail.com',
    )
  end

  let(:creator) { double(:creator, id: 1234) }

  let(:incoming_email_record){ double(:incoming_email_record, id: 8342, params: params, groups: [], organization: organization, creator: creator, parent_message: nil) }
  let(:incoming_email){ described_class.new(threadable, incoming_email_record) }
  let(:organization){ double(:organization, members: double(:members, find_by_user_id: member), subject_tag: 'foo', hold_all_messages?: false) }
  let(:member) { double(:member, role: :member)}
  let(:owner) { double(:owner, role: :owner)}

  subject{ incoming_email }

  it{ is_expected.to have_constant :Attachments }
  it{ is_expected.to have_constant :Bounce }
  it{ is_expected.to have_constant :Deliver }
  it{ is_expected.to have_constant :Process }

  it { is_expected.to delegate(:id        ).to(:incoming_email_record) }
  it { is_expected.to delegate(:to_param  ).to(:incoming_email_record) }
  it { is_expected.to delegate(:params    ).to(:incoming_email_record) }
  it { is_expected.to delegate(:processed?).to(:incoming_email_record) }
  it { is_expected.to delegate(:bounced?  ).to(:incoming_email_record) }
  it { is_expected.to delegate(:held?     ).to(:incoming_email_record) }
  it { is_expected.to delegate(:created_at).to(:incoming_email_record) }
  it { is_expected.to delegate(:errors    ).to(:incoming_email_record) }
  it { is_expected.to delegate(:persisted?).to(:incoming_email_record) }


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
        allow(incoming_email).to receive_message_chain(:organization, :members, :who_are_owners).and_return [owner]
      end

      it 'sends out the held message notice and marks its self as held' do
        allow(incoming_email).to receive_message_chain(:organization, :hold_all_messages?).and_return false
        expect(threadable.emails).to receive(:send_email).with(:message_held_notice, incoming_email)
        expect(threadable.emails).to receive(:send_email).with(:message_held_owner_notice, incoming_email, owner)
        expect(incoming_email).to receive(:held!)
        incoming_email.hold!
      end
      context 'when the organization holds all messages' do
        it 'just marks its self as held' do
          allow(incoming_email).to receive_message_chain(:organization, :hold_all_messages?).and_return true
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
      it { is_expected.to be_falsey }
    end
    context 'when organization is not nil' do
      let(:organization){ double(:organization, members: double(:members)) }
      before{ expect(incoming_email).to receive(:organization).at_least(1).times.and_return(organization) }
      context 'when creator is nil' do
        before{ expect(incoming_email).to receive(:creator).and_return(nil) }
        it { is_expected.to be_falsey }
      end
      context 'when creator is not nil' do
        let(:creator){ double(:creator) }
        before{ expect(incoming_email).to receive(:creator).at_least(1).times.and_return(creator) }
        context 'when organization.members.include?(creator) returns true' do
          before{ expect(organization.members).to receive(:include?).with(creator).and_return(true) }
          it { is_expected.to be_truthy }
        end
        context 'when organization.members.include?(creator) returns false' do
          before{ expect(organization.members).to receive(:include?).with(creator).and_return(false) }
          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe 'spam?' do
    subject{ incoming_email.spam? }

    context 'when the creator is a threadable member' do
      before{ allow(incoming_email).to receive_message_chain(:creator, :present?).and_return(true) }
      it { is_expected.to be_falsey }
    end

    context 'when the creator is not a threadable member' do
      before{ allow(incoming_email).to receive_message_chain(:creator, :present?).and_return(false) }

      context 'when the spam score is > 5' do
        before{ expect(incoming_email).to receive(:spam_score).and_return(10) }
        it { is_expected.to be_truthy }
      end

      context 'when the spam score is < 5' do
        before{ expect(incoming_email).to receive(:spam_score).and_return(-0.75) }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe 'delivered?' do
    subject{ incoming_email.delivered? }

    context 'when processed? returns false' do
      before{ expect(incoming_email).to receive(:processed?).and_return(false) }
      it { is_expected.to be_falsey }
    end

    context 'when processed? returns true' do
      before{ expect(incoming_email).to receive(:processed?).and_return(true) }

      context 'when held? returns true' do
        before{ expect(incoming_email).to receive(:held?).and_return(true) }
        it { is_expected.to be_falsey }
      end

      context 'when held? returns false' do
        before{ expect(incoming_email).to receive(:held?).and_return(false) }

        context 'when bounced? returns true' do
          before{ expect(incoming_email).to receive(:bounced?).and_return(true) }
          it { is_expected.to be_falsey }
        end

        context 'when bounced? returns false' do
          before{ expect(incoming_email).to receive(:bounced?).and_return(false) }

          context 'when a message is present' do
            before{ expect(incoming_email).to receive(:message).and_return(nil) }
            it { is_expected.to be_falsey }
          end

          context 'when a message is not present' do
            before{ expect(incoming_email).to receive(:message).and_return('6') }
            it { is_expected.to be_truthy }
          end
        end
      end
    end
  end

  describe 'dropped?' do
    subject{ incoming_email.dropped? }

    context 'when processed? returns false' do
      before{ expect(incoming_email).to receive(:processed?).and_return(false) }
      it { is_expected.to be_falsey }
    end

    context 'when processed? returns true' do
      before{ expect(incoming_email).to receive(:processed?).and_return(true) }

      context 'when held? returns true' do
        before{ expect(incoming_email).to receive(:held?).and_return(true) }
        it { is_expected.to be_falsey }
      end

      context 'when held? returns false' do
        before{ expect(incoming_email).to receive(:held?).and_return(false) }

        context 'when bounced? returns true' do
          before{ expect(incoming_email).to receive(:bounced?).and_return(true) }
          it { is_expected.to be_falsey }
        end

        context 'when bounced? returns false' do
          before{ expect(incoming_email).to receive(:bounced?).and_return(false) }

          context 'when a message is present' do
            before{ expect(incoming_email).to receive(:message).and_return(nil) }
            it { is_expected.to be_truthy }
          end

          context 'when a message is not present' do
            before{ expect(incoming_email).to receive(:message).and_return('6') }
            it { is_expected.to be_falsey }
          end
        end
      end
    end
  end


  describe 'bounceable?' do
    subject{ incoming_email.bounceable? }

    context 'when the message is spam' do
      before{ expect(incoming_email).to receive(:spam?).and_return(true) }
      it { is_expected.to be_falsey }
    end

    context 'when the message is not spam' do
      before{ expect(incoming_email).to receive(:spam?).and_return(false) }

      context 'when there is a bounce reason' do
        before{ expect(incoming_email).to receive(:bounce_reason).and_return(:blank_message) }
        it { is_expected.to be_truthy }
      end

      context 'when there is not a bounce reason' do
        before{ expect(incoming_email).to receive(:bounce_reason).and_return(nil) }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe 'holdable?' do
    subject{ incoming_email.holdable? }

    context 'when the message is not addressed to an organization' do
      before{ allow(incoming_email).to receive(:organization).and_return(nil) }

      it {is_expected.to be_falsey}
    end

    # the other cases are tested in spec/integration/threadable/incoming_email_spec.rb
  end

  describe 'deliverable?' do
    subject{ incoming_email.deliverable? }
    context 'when bounceable? is true' do
      before{ expect(incoming_email).to receive(:bounceable?).and_return(true) }
      it { is_expected.to be_falsey }
    end
    context 'when bounceable? is false' do
      before{ expect(incoming_email).to receive(:bounceable?).and_return(false) }
      context 'when droppable? is true' do
        before{ expect(incoming_email).to receive(:droppable?).and_return(true) }
        it { is_expected.to be_falsey }
      end
      context 'when droppable? is false' do
        before{ expect(incoming_email).to receive(:droppable?).and_return(false) }
        context 'when holdable? is false' do
          before{ expect(incoming_email).to receive(:holdable?).and_return(false) }
          it { is_expected.to be_truthy }
        end
        context 'when holdable? is true' do
          before{ expect(incoming_email).to receive(:holdable?).and_return(true) }
          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe 'droppable?' do
    subject{ incoming_email.droppable? }

    context 'when there is a parent message' do
      before{ expect(incoming_email).to receive(:parent_message).and_return(34543) }

      context 'and it contains only commands and whitespace' do
        before { expect(incoming_email).to receive(:command_only_message?).and_return(true) }
        it { is_expected.to be_truthy }
      end

      context 'and it has non-command content' do
        before { expect(incoming_email).to receive(:command_only_message?).and_return(false) }

        context 'and it would not otherwise bounce' do
          before { expect(incoming_email).to receive(:bounce_reason).and_return(nil) }

          context 'and it will not be held' do
            before{ expect(incoming_email).to receive(:hold_candidate?).and_return(false) }
            it { is_expected.to be_falsey }
          end
        end
      end
    end

    context 'when there is no parent message' do
      before{ expect(incoming_email).to receive(:parent_message).and_return(nil) }

      context 'when the message would have bounced' do
        before{ expect(incoming_email).to receive(:bounce_reason).and_return(:insufficient_kittens) }
        it { is_expected.to be_truthy }
      end

      context 'when the message would not have bounced' do
        before{ expect(incoming_email).to receive(:bounce_reason).and_return(nil) }

        context 'when the message could be held' do
          before{ expect(incoming_email).to receive(:hold_candidate?).and_return(true) }

          context 'when the message is spam' do
            before{ expect(incoming_email).to receive(:spam?).and_return(true) }
            it { is_expected.to be_truthy }
          end

          context 'when the message is not spam' do
            before{ expect(incoming_email).to receive(:spam?).and_return(false) }
            it { is_expected.to be_falsey }
          end
        end
      end
    end
  end

  describe '#bounce_reason' do
    subject{ incoming_email.bounce_reason }
    context 'when organization is nil' do
      before{ expect(incoming_email).to receive(:organization).and_return(nil) }
      it { is_expected.to eq :missing_organization_or_group }
    end
    context 'when organization is not nil' do
      before{ expect(incoming_email).to receive(:organization).and_return(organization) }

      context 'when the subject is valid' do
        before { expect(incoming_email).to receive(:subject_valid?).and_return(true) }

        context 'when the groups are valid' do
          before { expect(incoming_email).to receive(:groups_valid?).and_return(true) }

          context 'when the conversation is valid' do
            before { expect(incoming_email).to receive(:conversation_valid?).and_return(true) }
            it { is_expected.to be_nil }
          end

          context 'when the conversation is not valid' do
            before { expect(incoming_email).to receive(:conversation_valid?).and_return(false) }
            it { is_expected.to eq :trashed_conversation }
          end
        end

        context 'when the groups are invalid' do
          before { expect(incoming_email).to receive(:groups_valid?).and_return(false) }
          it { is_expected.to eq :missing_organization_or_group }
        end
      end

      context 'when the subject is invalid' do
        before { expect(incoming_email).to receive(:subject_valid?).and_return(false) }
        it { is_expected.to eq :blank_message }
      end
    end
  end

  describe '#subject_valid?' do
    let(:subject_line) { '[task] i am a subject line' }
    let(:body) { 'a message body' }

    subject{ incoming_email.subject_valid? }

    before do
      allow(incoming_email).to receive(:subject).and_return(subject_line)
      allow(incoming_email).to receive(:stripped_plain).and_return(body)
      allow(incoming_email).to receive(:organization).and_return(double(:organization, subject_tag: 'subject-tag', groups: double(:groups, all: [])))
    end

    it { is_expected.to be_truthy }

    context 'with a subject containing only things that are stripped' do
      let(:subject_line) { '[task][subject-tag] '}
      context 'with a plaintext body' do
        let(:body) { "I've got a lovely bunch of coconuts, here they are standing in a row" }
        it { is_expected.to be_truthy }
      end

      context 'with a plaintext body containing no words' do
        let(:body) { ' ' }
        it { is_expected.to be_falsey }
      end
    end

    context 'with a blank subject line and a blank body' do
      let(:subject_line) { '' }
      let(:body) { '' }

      it { is_expected.to be_falsey }
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
      allow(incoming_email).to receive_messages groups: groups, email_address_tags: email_address_tags
      allow(incoming_email.organization).to receive_message_chain(:groups, :primary, :email_address_tag).and_return('primary_tag')
    end

    subject{ incoming_email.groups_valid? }
    it {is_expected.to be_truthy}

    context 'with an extra email address tag' do
      let(:email_address_tags) { ['group1', 'group2', 'eeevil'] }
      it {is_expected.to be_truthy}
    end

    # not sure how this would ever happen
    context 'missing an email address tag' do
      let(:email_address_tags) { ['group1'] }
      it {is_expected.to be_falsey}
    end
  end

  describe '#conversation_valid' do
    context 'with a conversation' do
      it 'checks whether the conversation is in the trash' do
        allow(incoming_email).to receive_message_chain(:conversation, :trashed?).and_return(true)
        expect(incoming_email.conversation_valid?).to be_falsey
      end
    end
  end

  describe '#command_only_message?' do
    subject{ incoming_email.command_only_message? }

    before do
      allow(incoming_email).to receive(:stripped_plain).and_return(body)
    end

    context 'with a blank body' do
      let(:body) { '' }
      it { is_expected.to be_falsey }
    end

    context 'with a body that contains only commands and random whitespace' do
      let(:body) { '&add Maria Rivera\n\n \n' }
      it { is_expected.to be_truthy }
    end

    context 'with a body that contains commands and real live text' do
      let(:body){
        %(&done\n\n Hello Seattle, I am a mountaineer, in the hills and highlands. I fall asleep in hospital parking lots.)
      }
      it { is_expected.to be_falsey }
    end
  end

  describe '#subject' do
    subject { super().subject }
    it { is_expected.to eq params['subject'] }
  end

  describe '#message_id' do
    subject { super().message_id }
    it { is_expected.to eq params['Message-Id'] }
  end

  describe '#from' do
    subject { super().from }
    it { is_expected.to eq params['from'] }
  end

  describe '#envelope_from' do
    subject { super().envelope_from }
    it { is_expected.to eq params['X-Envelope-From'] }
  end

  describe '#sender' do
    subject { super().sender }
    it { is_expected.to eq params['sender'] }
  end

  describe '#recipient' do
    subject { super().recipient }
    it { is_expected.to eq params['recipient'] }
  end

  describe '#to' do
    subject { super().to }
    it { is_expected.to eq params['To'] }
  end

  describe '#cc' do
    subject { super().cc }
    it { is_expected.to eq params['Cc'] }
  end

  describe '#content_type' do
    subject { super().content_type }
    it { is_expected.to eq params['Content-Type'] }
  end

  describe '#date' do
    subject { super().date }
    it { is_expected.to eq Time.parse(params['Date']).in_time_zone }
  end

  describe '#in_reply_to' do
    subject { super().in_reply_to }
    it { is_expected.to eq params['In-Reply-To'] }
  end

  describe '#references' do
    subject { super().references }
    it { is_expected.to eq params['References'] }
  end

  describe '#message_headers' do
    subject { super().message_headers }
    it { is_expected.to eq JSON.parse(params['message-headers']) }
  end

  describe '#message_headers_as_hash' do
    subject { super().message_headers_as_hash }
    it { is_expected.to eq Hash[JSON.parse(params['message-headers'])] }
  end

  describe '#body_html' do
    subject { super().body_html }
    it { is_expected.to eq params['body-html'] }
  end

  describe '#body_plain' do
    subject { super().body_plain }
    it { is_expected.to eq params['body-plain'] }
  end

  describe '#stripped_html' do
    subject { super().stripped_html }
    it { is_expected.to eq params['stripped-html'] }
  end

  describe '#stripped_plain' do
    subject { super().stripped_plain }
    it { is_expected.to eq params['stripped-text'] }
  end

  describe '#from_email_addresses' do
    subject { super().from_email_addresses }
    it { is_expected.to eq ['alice@ucsd.example.com', 'alice.neilson@gmail.com'] }
  end


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
    it 'refers the call to the organization' do
      allow(incoming_email).to receive(:organization).and_return(organization)
      expect(organization).to receive(:email_address_tags).with(params['recipient'])
      incoming_email.email_address_tags
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
          allow(incoming_email).to receive_messages(conversation: nil)
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
          allow(incoming_email).to receive_messages(conversation: conversation)
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
          allow(incoming_email).to receive(:conversation).and_return(other_conversation)
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

  it { is_expected.to delegate(:header    ).to(:mail_message) }
  it { is_expected.to delegate(:multipart?).to(:mail_message) }

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

    describe '#inspect' do
      subject { super().inspect }
      it { is_expected.to eq %(#<Threadable::IncomingEmail id: 4589, processed: true, bounced: false, held: false, delivered: true, from: "alice@ucsd.example.com", creator_id: 12, organization_id: 13, conversation_id: 14, message_id: 15>) }
    end
  end

end
