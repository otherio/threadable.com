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

  let(:project_id  ){ 1 }
  let(:message_id  ){ 2 }
  let(:recipient_id){ 3 }

  let(:current_user){ double :current_user }

  let(:projects    ){ double :projects }
  let(:messages    ){ double :messages }
  let(:members     ){ double :members  }
  let(:users       ){ double :users    }

  let(:project     ){ double :project }
  let(:message     ){ double :message }
  let(:recipient   ){ double :recipient }

  describe 'conversation_message' do
    let(:arguments){ [:conversation_message, project_id, message_id, recipient_id] }
    it "should find all the records and call covered.emails.send_email" do
      expect_any_instance_of(Covered::Class).to receive(:projects).and_return(projects)
      expect(projects).to receive(:find_by_id!     ).with(project_id).and_return(project)

      expect(project ).to receive(:messages        ).and_return(messages)
      expect(messages).to receive(:find_by_id!     ).with(message_id).and_return(message)

      expect(project ).to receive(:members         ).and_return(members)
      expect(members ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Covered::Emails).to receive(:send_email).with(:conversation_message, project, message, recipient)

      perform!
    end
  end

  describe 'join_notice' do
    let(:personal_message){ "i need you!" }
    let(:arguments){ [:join_notice, project_id, recipient_id, personal_message] }
    it "should find all the records and call covered.emails.send_email" do
      expect_any_instance_of(Covered::Class).to receive(:projects).and_return(projects)
      expect(projects      ).to receive(:find_by_id!     ).with(project_id).and_return(project)

      expect(project       ).to receive(:members         ).and_return(members)
      expect(members       ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Covered::Emails).to receive(:send_email).with(:join_notice, project, recipient, personal_message)

      perform!
    end
  end

  describe 'unsubscribe_notice' do
    let(:arguments){ [:unsubscribe_notice, project_id, recipient_id] }
    it "should find all the records and call covered.emails.send_email" do
      expect_any_instance_of(Covered::Class).to receive(:projects).and_return(projects)
      expect(projects      ).to receive(:find_by_id!     ).with(project_id).and_return(project)

      expect(project       ).to receive(:members         ).and_return(members)
      expect(members       ).to receive(:find_by_user_id!).with(recipient_id).and_return(recipient)

      expect_any_instance_of(Covered::Emails).to receive(:send_email).with(:unsubscribe_notice, project, recipient)

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
