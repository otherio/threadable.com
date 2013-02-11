require 'spec_helper'

describe ApplicationHelper do
  describe "#avatar_url" do
    subject { avatar_url(user) }

    context "with a user with no local avatar" do
      let(:user) { create(:user, email: 'foo@example.com') }

      it "returns a url for a gravatar with no user avatar url present" do
        url = subject
        url.should include(Digest::MD5.hexdigest(user.email.downcase))
        url.should =~ %r{^http://gravatar.com/}
      end
    end

    context "with a user who has a local avatar" do
      let(:user) { create(:user, email: 'foo@example.com', avatar_url: 'http://example.com/') }

      it "returns the local url" do
        url = subject
        url.should == 'http://example.com/'
      end
    end
  end
end
