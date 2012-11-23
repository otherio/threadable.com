require "spec_helper"

describe AddedToTask do
  describe "as_doer" do
    let(:mail) { AddedToTask.as_doer }

    it "renders the headers" do
      mail.subject.should eq("As doer")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "as_follower" do
    let(:mail) { AddedToTask.as_follower }

    it "renders the headers" do
      mail.subject.should eq("As follower")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
