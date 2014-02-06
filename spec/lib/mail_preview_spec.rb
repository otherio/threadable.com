require 'spec_helper'

describe MailPreview do

  describe "conversation_message" do
    subject{ MailPreview.new.conversation_message }
    it { should be_a Mail::Message }
  end

  describe "task_message" do
    subject{ MailPreview.new.task_message }
    it { should be_a Mail::Message }
  end

  describe "join_notice" do
    subject{ MailPreview.new.join_notice }
    it { should be_a Mail::Message }
  end

  describe "unsubscribe_notice" do
    subject{ MailPreview.new.unsubscribe_notice }
    it { should be_a Mail::Message }
  end

  describe "sign_up_confirmation" do
    subject{ MailPreview.new.sign_up_confirmation }
    it { should be_a Mail::Message }
  end

  describe "reset_password" do
    subject{ MailPreview.new.reset_password }
    it { should be_a Mail::Message }
  end

  describe "message_summary" do
    subject{ MailPreview.new.message_summary }
    it { should be_a Mail::Message }
  end

end
