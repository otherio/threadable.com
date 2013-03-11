require "spec_helper"
require 'base64'

describe UnsubscribeToken do
  let(:userid) { 12345 }
  let(:projectid) { 56789 }
  let(:time) { Time.new(2013,01,01) }

  before do
    Timecop.freeze(time)
  end

  after do
    Timecop.return
  end

  context "making a token" do
    subject { UnsubscribeToken.new(user_id: userid, project_id: projectid) }

    it "makes a token" do
      subject.token.should be_a(String)
    end
  end

  context "decrypting the token" do
    let(:token) { UnsubscribeToken.new(user_id: userid, project_id: projectid).token }
    subject { UnsubscribeToken.new(token: token) }

    it "decrypts the token" do
      subject.user_id.should == userid
      subject.project_id.should == projectid
      subject.time.should == time
    end
  end
end
