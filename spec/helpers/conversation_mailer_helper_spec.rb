require 'spec_helper'

describe ConversationMailerHelper, :type => :helper do

  let(:conversation){ double(:conversation, id: 993) }
  let(:recipient)   { double(:recipient, id: 84) }

  describe "#email_action_link" do
    it "creates a mailto link for &done" do
      href = helper.email_action_link(conversation, recipient, 'done')
      token = Rails.application.routes.recognize_path(href)[:token]
      expect(EmailActionToken.decrypt(token)).to eq [993, 84, "done"]
    end
  end
end


