require 'spec_helper'

describe Organization do

  it "should require a name" do
    organization = Organization.new
    organization.save.should be_false
    organization.errors[:name].should == ["can't be blank"]

    organization.name = 'build a hyper cube'
    organization.save.should be_true
    organization.errors.should be_blank
  end

  it "should require a uniq name" do
    organization = Organization.new(name: 'build a fire proof house')
    organization.save.should be_true

    organization = Organization.new(name: 'build a fire proof house')
    organization.save.should be_false
    organization.errors[:name].should == ["has already been taken"]
  end

  context "when not given a slug" do
    it "should be created from the name if blank" do
      organization = Organization.create(name: 'Fall down a hole')
      organization.slug.should == 'fall-down-a-hole'
    end
  end

  describe "#short_name=" do

    context "when the name is 'Langworth, Barton and Strosin ™'" do
      let(:organization){ Organization.create(name: name, short_name: short_name) }
      let(:name){ "Langworth, Barton and Strosin ™" }
      context "and the short_name is nil" do
        let(:short_name){ nil }
        describe "#slug" do
          subject{ organization.slug }
          it { should == 'langworth-barton-and-strosin'}
        end
        describe "#subject_tag" do
          subject{ organization.subject_tag }
          it { should == 'Langworth Barton and Strosin'}
        end
        describe "#email_address_username" do
          subject{ organization.email_address_username }
          it { should == 'langworth-barton-and-strosin'}
        end
      end

      context "and the short_name is 'LBS'" do
        let(:short_name){ "LBS ™" }
        describe "#slug" do
          subject{ organization.slug }
          it { should == 'lbs'}
        end
        describe "#subject_tag" do
          subject{ organization.subject_tag }
          it { should == 'LBS'}
        end
        describe "#email_address_username" do
          subject{ organization.email_address_username }
          it { should == 'lbs'}
        end
      end
    end
  end

  describe "#slug" do
    it "should be generated from the short name" do
      organization = Organization.create(name: 'Fly to the moon', short_name: 'Moon Mission')
      expect(organization.slug).to eq 'moon-mission'
      organization.update_attributes(short_name: 'Mission to Moon')
      expect(organization.slug).to eq 'mission-to-moon'
    end
  end

  describe "#email_address_username" do

    def email_address_username_errors email_address_username
      organization = described_class.new(:email_address_username => email_address_username)
      organization.valid?
      organization.errors[:email_address_username]
    end

    it "validates the format of" do
      expect( email_address_username_errors("hello") ).to be_blank
      expect( email_address_username_errors("hello there") ).to eq ["is invalid"]
      expect( email_address_username_errors("hello_there") ).to be_blank
      expect( email_address_username_errors("hello-there") ).to be_blank
    end
  end

end
