require 'spec_helper'

describe Conversation, :type => :model do
  it { is_expected.to belong_to(:organization) }
  it { is_expected.to have_many(:messages) }

  context "slug" do
    let :conversation do
      described_class.create(organization_id: 1, subject: 'foo bar Baz!')
    end

    it "has a correct slug" do
      expect(conversation.slug).to eq('foo-bar-baz')
    end
  end

  describe "when the slug matchs another route" do

    it "should suffix the slug with - n until it is uniq" #do
    #   5.times do |i|
    #     conversation = FactoryGirl.build(:conversation, subject:'new')
    #     conversation.save.should be_true
    #     conversation.slug.should == "new-#{i+1}"
    #   end
    # end

  end

end
