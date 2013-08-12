require 'spec_helper'

describe EmailProcessor::ProjectEmailAddressUsernameFinder do

  context "when given an array of email addresses that looks like a project email" do
    context "for production" do
      let(:to){ [Faker::Internet.email, 'make-a-duck@beta.covered.io', Faker::Internet.email] }
      it "should return the slug for that project" do
        expect(EmailProcessor::ProjectEmailAddressUsernameFinder.call(to)).to eq 'make-a-duck'
      end
    end
    context "for staging" do
      let(:to){ [Faker::Internet.email, 'make-a-duck@www-staging.covered.io', Faker::Internet.email] }
      it "should return the slug for that project" do
        expect(EmailProcessor::ProjectEmailAddressUsernameFinder.call(to)).to eq 'make-a-duck'
      end
    end
  end

  context "when given an array of email addresses that doesnt look like a project email" do
    let(:to){ [Faker::Internet.email, Faker::Internet.email, Faker::Internet.email] }
    it "should return nil" do
      expect(EmailProcessor::ProjectEmailAddressUsernameFinder.call(to)).to be_nil
    end
  end

end
