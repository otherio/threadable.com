require 'spec_helper'

describe ConversationMailerHelper do

  let(:conversation){ double(:conversation, task?: true, organization: organization, slug: 'layup-body-carbon')}
  let(:organization){ double(:organization, email_address: "raceteam@yourmom.com", task_email_address: "raceteam+task@yourmom.com", )}

  describe "#email_command_link" do
    it "creates a mailto link for &done" do
      expect(helper.email_command_link(conversation, "Re: [raceteam] Layup Body Carbon", 'done')).to eq \
        %(mailto:raceteam+task@yourmom.com?)+
        %(body=--%20don%27t%20delete%20this%3A%20%5Bref%3A%20layup-body-carbon%5D%0A)+
        %(--%20tip%3A%20control%20covered%20by%20putting%20commands%20at%20the%20top%20of%20your%20reply%2C%20just%20like%20this%3A%0A%0A%26done&)+
        %(subject=Re%3A%20%5Braceteam%5D%20Layup%20Body%20Carbon)
    end
  end
end


