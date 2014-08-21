require 'spec_helper'

describe Organization, :type => :model do

  it "should require a name" do
    organization = Organization.new
    expect(organization.save).to be_falsey
    expect(organization.errors[:name]).to eq(["can't be blank"])

    organization.name = 'build a hyper cube'
    expect(organization.save).to be_truthy
    expect(organization.errors).to be_blank
  end

  context "when not given a slug" do
    it "should be created from the name if blank" do
      organization = Organization.create(name: 'Fall down a hole')
      expect(organization.slug).to eq('fall-down-a-hole')
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
          it { is_expected.to eq('langworth-barton-and-strosin')}
        end
        describe "#subject_tag" do
          subject{ organization.subject_tag }
          it { is_expected.to eq('Langworth Barton and Strosin')}
        end
        describe "#email_address_username" do
          subject{ organization.email_address_username }
          it { is_expected.to eq('langworth-barton-and-strosin')}
        end
      end

      context "and the short_name is 'LBS'" do
        let(:short_name){ "LBS ™" }
        describe "#slug" do
          subject{ organization.slug }
          it { is_expected.to eq('lbs')}
        end
        describe "#subject_tag" do
          subject{ organization.subject_tag }
          it { is_expected.to eq('LBS')}
        end
        describe "#email_address_username" do
          subject{ organization.email_address_username }
          it { is_expected.to eq('lbs')}
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
      expect( email_address_username_errors("hello+there") ).to eq ["is invalid"]
      expect( email_address_username_errors("hello--there") ).to eq ["is invalid"]
      expect( email_address_username_errors("hello.there") ).to eq ["is invalid"]
      expect( email_address_username_errors("hello_there") ).to be_blank
      expect( email_address_username_errors("hello-there") ).to be_blank
    end
  end

end
