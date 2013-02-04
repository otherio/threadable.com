require 'spec_helper'

describe Conversation do
  it { should belong_to(:project) }
  it { should have_many(:messages) }

  context "slug" do
    let(:conversation) {Conversation.create(
      subject: 'foo bar Baz!'
    )}

    it "has a correct slug" do
      conversation.slug.should == 'foo-bar-baz'
    end
  end
end
