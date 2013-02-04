require 'spec_helper'

describe Conversation do
  it { should have_many(:messages) }
  it { should belong_to(:project) }
  it { should belong_to(:task) }

  context "slug" do
    let(:conversation) {Conversation.create(
      subject: 'foo bar Baz!'
    )}

    it "has a correct slug" do
      conversation.slug.should == 'foo-bar-baz'
    end
  end
end
