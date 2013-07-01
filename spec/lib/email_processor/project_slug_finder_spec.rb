require 'spec_helper'

describe EmailProcessor::ProjectSlugFinder do

  context "when given an array of email addresses that looks like a project email" do
    context "for production" do
      let(:to){ [Faker::Internet.email, 'make-a-duck@beta.coveredapp.com', Faker::Internet.email] }
      it "should return the slug for that project" do
        expect(EmailProcessor::ProjectSlugFinder.call(to)).to eq 'make-a-duck'
      end
    end
    context "for staging" do
      let(:to){ [Faker::Internet.email, 'make-a-duck@www-staging.coveredapp.com', Faker::Internet.email] }
      it "should return the slug for that project" do
        expect(EmailProcessor::ProjectSlugFinder.call(to)).to eq 'make-a-duck'
      end
    end
  end

  context "when given an array of email addresses that doesnt look like a project email" do
    let(:to){ [Faker::Internet.email, Faker::Internet.email, Faker::Internet.email] }
    it "should return nil" do
      expect(EmailProcessor::ProjectSlugFinder.call(to)).to be_nil
    end
  end

end
