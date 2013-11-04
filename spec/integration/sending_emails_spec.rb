require 'spec_helper'

describe 'sending emails' do

  def validate_email! email
    expect(email).to be_present
    email.urls.each do |url|
      expect(url.host).to eq covered.host
      expect(url.port).to eq covered.port
    end
  end

  describe 'conversation_message' do
    let(:project  ){ find_project('raceteam') }
    let(:message  ){ project.messages.first!  }
    let(:recipient){ project.members.first!   }

    it "should schedule a background job that send the email" do
      covered.send_email(:conversation_message, message_id: message.id, recipient_id: recipient.id)
      assert_background_job_enqueued(covered, :send_email,
        type: :conversation_message,
        options: {message_id: message.id, recipient_id: recipient.id}
      )
      run_background_jobs!
      email = sent_emails.to(recipient.email).with_subject("[RaceTeam] Welcome to our new Covered project!").first
      validate_email! email
    end
  end

  describe 'join_notice' do
    let(:project  ){ find_project('raceteam') }
    let(:current_user){ project.members.first! }
    let(:recipient){ project.members.last!   }

    it "should schedule a background job that send the email" do
      covered.send_email(:join_notice, project_id: project.id, recipient_id: recipient.id)
      assert_background_job_enqueued(covered, :send_email,
        type: :join_notice,
        options: {project_id: project.id, recipient_id: recipient.id}
      )
      run_background_jobs!
      email = sent_emails.to(recipient.email).with_subject("You've been added to UCSD Electric Racing").first
      validate_email! email
    end
  end

  describe 'unsubscribe_notice' do
    let(:project  ){ find_project('raceteam') }
    let(:recipient){ project.members.last!   }

    it "should schedule a background job that send the email" do
      covered.send_email(:unsubscribe_notice, project_id: project.id, recipient_id: recipient.id)
      assert_background_job_enqueued(covered, :send_email,
        type: :unsubscribe_notice, options: {project_id: project.id, recipient_id: recipient.id}
      )
      run_background_jobs!
      email = sent_emails.to(recipient.email).with_subject("You've been unsubscribed from UCSD Electric Racing").first
      validate_email! email
    end
  end

  describe 'sign_up_confirmation' do
    let(:recipient){ find_user 'john-callas' }

    it "should schedule a background job that send the email" do
      covered.send_email(:sign_up_confirmation, recipient_id: recipient.id)
      assert_background_job_enqueued(covered, :send_email,
        type: :sign_up_confirmation, options: {recipient_id: recipient.id}
      )
      run_background_jobs!
      email = sent_emails.to(recipient.email).with_subject("Welcome to Covered!").first
      validate_email! email
    end
  end

  describe 'reset_password' do
    let(:recipient){ find_user 'john-callas' }

    it "should schedule a background job that send the email" do
      covered.send_email(:reset_password, recipient_id: recipient.id)
      assert_background_job_enqueued(covered, :send_email,
        type: :reset_password, options: {recipient_id: recipient.id}
      )
      run_background_jobs!
      email = sent_emails.to(recipient.email).with_subject("Reset your password!").first
      validate_email! email
    end
  end

end
