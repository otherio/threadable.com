require 'spec_helper'

describe Conversation do
  it { should belong_to(:organization) }
  it { should have_many(:messages) }

  context "slug" do
    let :conversation do
      described_class.create(organization_id: 1, subject: 'foo bar Baz!')
    end

    it "has a correct slug" do
      conversation.slug.should == 'foo-bar-baz'
    end
  end

  describe "when the slug matchs another route" do

    it "should suffix the slug with - n until it is uniq" do
      5.times do |i|
        conversation = FactoryGirl.build(:conversation, subject:'new')
        conversation.save.should be_true
        conversation.slug.should == "new-#{i+1}"
      end
    end

  end

  describe 'recipients' do
    let(:conversation1){ find_conversation_by_slug 'welcome-to-our-covered-organization' }
    let(:conversation2){ find_conversation_by_slug 'how-are-we-going-to-build-the-body'  }
    let(:organization) { conversation1.organization }
    it 'returns all the organization members who get email minus all the conversation muters' do
      expect(conversation1.muters.count).to eq 1
      expect(conversation1.recipients.count).to eq 4
      expect(conversation2.muters.count).to eq 0
      expect(conversation2.recipients.count).to eq 5

      expect(organization.members.who_get_email.count).to eq 5

      expect(conversation1.recipients).to eq organization.members.who_get_email - conversation1.muters
      expect(conversation2.recipients).to eq organization.members.who_get_email
    end
  end

end
