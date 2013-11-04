require 'spec_helper'

describe Covered::Users do

  subject{ described_class.new covered }

  describe "#covered" do
    it "should eq the given instance of Covered" do
      expect(subject.covered).to eq covered
    end
  end

  describe "#get" do
    it "should take a Covered::User#slug and return a Covered::User" do
      user = Covered::User.first!
      expect( subject.get(slug: user.slug) ).to eq user
      expect{ subject.get(slug: 'lolcandybar') }.to raise_error Covered::RecordNotFound
    end
  end

end
