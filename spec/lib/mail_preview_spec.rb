require 'spec_helper'

describe MailPreview do

  describe "conversation_message" do
    subject{ MailPreview.new.conversation_message }
    it { is_expected.to be_a Mail::Message }
  end

  describe "task_message" do
    subject{ MailPreview.new.task_message }
    it { is_expected.to be_a Mail::Message }
  end

  describe "join_notice" do
    subject{ MailPreview.new.join_notice }
    it { is_expected.to be_a Mail::Message }
  end

  describe "join_notice" do
    subject{ MailPreview.new.self_join_notice }
    it { is_expected.to be_a Mail::Message }
  end

  describe "join_notice" do
    subject{ MailPreview.new.self_join_notice_confirm }
    it { is_expected.to be_a Mail::Message }
  end

  describe "unsubscribe_notice" do
    subject{ MailPreview.new.unsubscribe_notice }
    it { is_expected.to be_a Mail::Message }
  end

  describe "sign_up_confirmation" do
    subject{ MailPreview.new.sign_up_confirmation }
    it { is_expected.to be_a Mail::Message }
  end

  describe "reset_password" do
    subject{ MailPreview.new.reset_password }
    it { is_expected.to be_a Mail::Message }
  end

  describe "message_summary" do
    subject{ MailPreview.new.message_summary }
    it { is_expected.to be_a Mail::Message }
  end

end
