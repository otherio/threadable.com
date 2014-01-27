require 'spec_helper'

describe SendEmailWorker do

  def perform!
    described_class.new.perform(covered.env, *arguments)
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

  let(:current_user){ double :current_user }

  let(:organizations    ){ double :organizations }
  let(:messages    ){ double :messages }
  let(:members     ){ double :members  }
  let(:users       ){ double :users    }

  let(:organization     ){ double :organization }
  let(:message     ){ double :message }
  let(:recipient   ){ double :recipient }
  let(:sent_email   ){ double :sent_email }

  describe 'conversation_message' do
    let(:arguments){ [:conversation_message, organization_id, message_id, recipient_id] }
    it "should find all the records and call covered.emails.send_email" do
      expect_any_instance_of(Covered::Class).to receive(:organizations).and_return(organizations)
      expect(organizations).to receive(:find_by_id!     ).with(organization_id).and_return(organization)

      expect(organization ).to receive(:messages        ).and_return(messages)
      expect(messages).to receive(:find_by_id!     ).with(message_id).and_return(message)

      expect(organization ).to receive(:members         ).and_return(members)
      expect(members ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect(message).to receive(:sent_email).with(recipient).and_return(sent_email)
      expect(sent_email).to receive(:relayed!)

      expect_any_instance_of(Covered::Emails).to receive(:send_email).with(:conversation_message, organization, message, recipient)

      perform!
    end
  end

  describe 'join_notice' do
    let(:personal_message){ "i need you!" }
    let(:arguments){ [:join_notice, organization_id, recipient_id, personal_message] }
    it "should find all the records and call covered.emails.send_email" do
      expect_any_instance_of(Covered::Class).to receive(:organizations).and_return(organizations)
      expect(organizations      ).to receive(:find_by_id!     ).with(organization_id).and_return(organization)

      expect(organization       ).to receive(:members         ).and_return(members)
      expect(members       ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Covered::Emails).to receive(:send_email).with(:join_notice, organization, recipient, personal_message)

      perform!
    end
  end

  describe 'unsubscribe_notice' do
    let(:arguments){ [:unsubscribe_notice, organization_id, recipient_id] }
    it "should find all the records and call covered.emails.send_email" do
      expect_any_instance_of(Covered::Class).to receive(:organizations).and_return(organizations)
      expect(organizations      ).to receive(:find_by_id!     ).with(organization_id).and_return(organization)

      expect(organization       ).to receive(:members         ).and_return(members)
      expect(members       ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Covered::Emails).to receive(:send_email).with(:unsubscribe_notice, organization, recipient)

      perform!
    end
  end

  describe 'sign_up_confirmation' do
    let(:arguments){ [:sign_up_confirmation, recipient_id] }
    it "should find all the records and call covered.emails.send_email" do
      expect_any_instance_of(Covered::Class).to receive(:users).and_return(users)
      expect(users).to receive(:find_by_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Covered::Emails).to receive(:send_email).with(:sign_up_confirmation, recipient)

      perform!
    end
  end

  describe 'reset_password' do
    let(:arguments){ [:reset_password, recipient_id] }
    it "should find all the records and call covered.emails.send_email" do
      expect_any_instance_of(Covered::Class).to receive(:users).and_return(users)
      expect(users).to receive(:find_by_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Covered::Emails).to receive(:send_email).with(:reset_password, recipient)

      perform!
    end
  end

end
