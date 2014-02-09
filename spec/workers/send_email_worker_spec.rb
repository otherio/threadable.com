require 'spec_helper'

describe SendEmailWorker do

  def perform!
    described_class.new.perform(threadable.env, *arguments)
  end

  describe 'perform!' do
    let(:arguments){ [:poop, :i, :love, :kakah!] }
    it "should send the type and curry the arguments" do
      expect_any_instance_of(described_class).to receive(:poop).with(:i, :love, :kakah!)
      perform!
    end
  end

  let(:organization_id  ){ 1 }
  let(:message_id  ){ 2 }
  let(:recipient_id){ 3 }
  let(:sender_id){ 4 }
  let(:group_id){ 5 }

  let(:current_user){ double :current_user }

  let(:organizations ){ double :organizations }
  let(:messages      ){ double :messages }
  let(:members       ){ double :members  }
  let(:users         ){ double :users    }
  let(:conversations ){ double :conversations    }
  let(:groups        ){ double :groups    }

  let(:organization ){ double :organization }
  let(:group        ){ double :group }
  let(:message      ){ double :message }
  let(:recipient    ){ double :recipient }
  let(:sender       ){ double :sender }
  let(:sent_email   ){ double :sent_email }

  describe 'conversation_message' do
    let(:arguments){ [:conversation_message, organization_id, message_id, recipient_id] }
    it "should find all the records and call threadable.emails.send_email" do
      expect_any_instance_of(Threadable::Class).to receive(:organizations).and_return(organizations)
      expect(organizations).to receive(:find_by_id!     ).with(organization_id).and_return(organization)

      expect(organization ).to receive(:messages        ).and_return(messages)
      expect(messages).to receive(:find_by_id!     ).with(message_id).and_return(message)

      expect(organization ).to receive(:members         ).and_return(members)
      expect(members ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect(message).to receive(:sent_email).with(recipient).and_return(sent_email)
      expect(sent_email).to receive(:relayed!)

      expect_any_instance_of(Threadable::Emails).to receive(:send_email).with(:conversation_message, organization, message, recipient)

      perform!
    end
  end

  describe 'message_summary' do
    let(:arguments){ [:message_summary, organization_id, recipient_id, date] }
    let(:date) { Time.new(1982,1,1) }  # this time is irrelevant.
    it "should find all the records and call threadable.emails.send_email" do
      expect_any_instance_of(Threadable::Class).to receive(:organizations).and_return(organizations)
      expect(organizations).to receive(:find_by_id!     ).with(organization_id).and_return(organization)

      expect(organization ).to receive(:conversations        ).and_return(conversations)
      expect(conversations).to receive(:all_with_updated_date        ).with(date).and_return(messages)

      expect(organization ).to receive(:members         ).and_return(members)
      expect(members ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Threadable::Emails).to receive(:send_email).with(:message_summary, organization, recipient, messages, date)

      perform!
    end
  end

  describe 'join_notice' do
    let(:personal_message){ "i need you!" }
    let(:arguments){ [:join_notice, organization_id, recipient_id, personal_message] }
    it "should find all the records and call threadable.emails.send_email" do
      expect_any_instance_of(Threadable::Class).to receive(:organizations).and_return(organizations)
      expect(organizations      ).to receive(:find_by_id!     ).with(organization_id).and_return(organization)

      expect(organization       ).to receive(:members         ).and_return(members)
      expect(members       ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Threadable::Emails).to receive(:send_email).with(:join_notice, organization, recipient, personal_message)

      perform!
    end
  end

  describe 'unsubscribe_notice' do
    let(:arguments){ [:unsubscribe_notice, organization_id, recipient_id] }
    it "should find all the records and call threadable.emails.send_email" do
      expect_any_instance_of(Threadable::Class).to receive(:organizations).and_return(organizations)
      expect(organizations ).to receive(:find_by_id!     ).with(organization_id).and_return(organization)

      expect(organization  ).to receive(:members         ).and_return(members)
      expect(members       ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Threadable::Emails).to receive(:send_email).with(:unsubscribe_notice, organization, recipient)

      perform!
    end
  end

  describe 'sign_up_confirmation' do
    let(:arguments){ [:sign_up_confirmation, recipient_id] }
    it "should find all the records and call threadable.emails.send_email" do
      expect_any_instance_of(Threadable::Class).to receive(:users).and_return(users)
      expect(users).to receive(:find_by_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Threadable::Emails).to receive(:send_email).with(:sign_up_confirmation, recipient)

      perform!
    end
  end

  describe 'reset_password' do
    let(:arguments){ [:reset_password, recipient_id] }
    it "should find all the records and call threadable.emails.send_email" do
      expect_any_instance_of(Threadable::Class).to receive(:users).and_return(users)
      expect(users).to receive(:find_by_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Threadable::Emails).to receive(:send_email).with(:reset_password, recipient)

      perform!
    end
  end

  describe 'added_to_group' do
    let(:arguments){ [:added_to_group_notice, organization_id, group_id, sender_id, recipient_id] }
    it "should find all the records and call threadable.emails.send_email" do
      expect_any_instance_of(Threadable::Class).to receive(:organizations).and_return(organizations)
      expect(organizations ).to receive(:find_by_id!     ).with(organization_id).and_return(organization)

      expect(organization  ).to receive(:members         ).twice.and_return(members)
      expect(members       ).to receive(:find_by_user_id!).with(sender_id).and_return(sender)
      expect(members       ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect(organization  ).to receive(:groups         ).and_return(groups)
      expect(groups        ).to receive(:find_by_id!    ).with(group_id).and_return(group)

      expect_any_instance_of(Threadable::Emails).to receive(:send_email).with(:added_to_group_notice, organization, group, sender, recipient)

      perform!
    end
  end

  describe 'removed_from_group' do
    let(:arguments){ [:removed_from_group_notice, organization_id, group_id, sender_id, recipient_id] }
    it "should find all the records and call threadable.emails.send_email" do
      expect_any_instance_of(Threadable::Class).to receive(:organizations).and_return(organizations)
      expect(organizations ).to receive(:find_by_id!     ).with(organization_id).and_return(organization)

      expect(organization  ).to receive(:members         ).twice.and_return(members)
      expect(members       ).to receive(:find_by_user_id!).with(sender_id).and_return(sender)
      expect(members       ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect(organization  ).to receive(:groups         ).and_return(groups)
      expect(groups        ).to receive(:find_by_id!    ).with(group_id).and_return(group)

      expect_any_instance_of(Threadable::Emails).to receive(:send_email).with(:removed_from_group_notice, organization, group, sender, recipient)

      perform!
    end
  end

end
