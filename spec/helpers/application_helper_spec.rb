require 'spec_helper'

describe ApplicationHelper do
  describe "#avatar_url" do
    subject { avatar_url(user) }

    context "when the user is not present" do
      let(:user){ nil }
      it { should == view.default_avatar_url }
    end

    context "when given a user with no local avatar" do
      let(:user) { double(:user, email: 'foo@example.com', avatar_url: nil) }

      it { should == "http://gravatar.com/avatar/b48def645758b95537d4424c84d1a9ff.png?s=24" }
    end

    context "with a user who has a local avatar" do
      let(:user) { double(:user, email: 'foo@example.com', avatar_url: '/avatars/foo.jpg') }
      it { should == '/avatars/foo.jpg' }
    end
  end
end
