require 'spec_helper'

describe Covered::User do

  subject(:user){ described_class.new }

  it { should have_many :email_addresses }
  it { should have_many :project_memberships }
  it { should have_many :projects }
  it { should have_many :messages }
  it { should have_many :conversations }
  it { should have_and_belong_to_many :tasks }

  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  # it { should validate_confirmation_of :password } # this is only when confirmed

  def build_user_with_password password
    FactoryGirl.build(:user, password: password, password_confirmation: password)
  end

  describe "password validations" do
    def user_attributes
      {}
    end

    let(:user){ build(:user, user_attributes) }

    subject{ user.errors_on(:password) }

    before{ user.valid? }

    it { should be_empty }

    context "when password is too short" do
      def user_attributes
        { password: "123", password_confirmation: "123" }
      end
      it { should eq ["is too short (minimum is 6 characters)"] }
    end

    context "when passwords do not match" do
      subject{ user.errors_on(:password_confirmation) }
      def user_attributes
        { password: "asjkdhjksadhjksa", password_confirmation: "2348392489320890" }
      end
      it { should eq ["doesn't match Password"] }
    end

    context "when password is present but password_confirmation is blank" do
      subject{ user.errors_on(:password_confirmation) }
      def user_attributes
        { password: "asjkdhjksadhjksa" }
      end
      it { should eq ["can't be blank"] }
    end

  end

  describe "factory" do
    def factory_options
      {email: 'foo@example.com'}
    end

    subject(:user){ build(:user, factory_options) }

    it "should have a valid factory" do
      expect(user).to be_valid
    end

    it "should use the gravatar as the default avatar when none is supplied" do
      expect(user.avatar_url).to eq 'http://gravatar.com/avatar/b48def645758b95537d4424c84d1a9ff.png?s=48&d=retro'
    end

    it "should not have a password" do
      expect(user.password).to be_nil
    end

    context "when web_enabled is true" do
      def factory_options
        super.merge(web_enabled: true)
      end
      it "should have a password" do
        expect(user.encrypted_password).to be_present
      end
    end

  end

  describe "email addresses" do

    before do
      user.email_addresses.build(address: 'primary@important.net', primary: true)
      user.email_addresses.build(address: 'other@stupid.net', primary: false)
    end

    describe "#primary_email_address" do
      it "should return the primary or first email address" do
        user.primary_email_address.address.should == 'primary@important.net'
      end
    end

    describe "#email" do
      it "should return the primary email address" do
        user.email.should == 'primary@important.net'
      end
    end

    describe "#email=" do
      it "should update the address of the primary email address" do
        user.email = 'foo@bar.love'
        user.email_addresses.map(&:address).to_set.should == Set['other@stupid.net','foo@bar.love']
      end
    end
  end

  describe "#as_json" do
    it "should include email by default" do
      user = FactoryGirl.build(:user)
      user.as_json['email'].should == user.email
    end
  end

  it "should validate_email_address_is_not_already_taken" do
    taken_email_address = Covered::EmailAddress.first.address
    user = Covered::User.new(email: taken_email_address)
    expect(user).to be_invalid
    expect(user.errors[:email]).to eq ["has already been taken"]
  end

end
