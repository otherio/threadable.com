require 'spec_helper'

describe User do

  subject(:user){ described_class.new }

  it { should have_many :email_addresses }
  it { should have_many :organization_memberships }
  it { should have_many :organizations }
  it { should have_many :messages }
  it { should have_many :conversations }
  it { should have_many :api_access_tokens }
  # it { should have_many :tasks } # somehow this is broken now as well

  it { should validate_presence_of :name }
  # it { should validate_presence_of :email_addresses } # somehow this is broken now

  it { should belong_to :organization }

  def build_user_with_password password
    FactoryGirl.build(:user, password: password, password_confirmation: password)
  end

  it "should ensure the user has a primary email address" do
    user = User.new
    user.valid?
    expect(user).to have(1).errors_on(:email_address)
    user = User.new email_address: 'love@it.com'
    user.valid?
    expect(user).to have(0).errors_on(:email_address)
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
      it { should eq ["doesn't match Password", "can't be blank"] }
    end

  end

  describe "factory" do
    def factory_options
      {email_address: 'foo@example.com'}
    end

    subject(:user){ build(:user, factory_options) }

    it "should have a valid factory" do
      expect(user).to be_valid
    end

    it "should use the gravatar as the default avatar when none is supplied" do
      expect(user.avatar_url).to eq '//gravatar.com/avatar/b48def645758b95537d4424c84d1a9ff.png?s=70&d=retro'
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

    subject(:user){ create(:user, email_address: 'primary@important.net') }

    before do
      user.email_addresses.create(address: 'other@stupid.net', primary: false)
    end

    describe "#email_address" do
      it "should return the primary email address" do
        user.email_address.should == 'primary@important.net'
      end
    end

    describe "#email_address=" do
      it "should update the address of the primary email address" do
        user.email_address = 'foo@bar.love'
        user.email_addresses.map(&:address).to_set.should == Set['primary@important.net', 'other@stupid.net','foo@bar.love']
      end

      it "downcases the address" do
        user.email_address = 'FoO@bar.love'
        user.email_addresses.map(&:address).to_set.should == Set['primary@important.net', 'other@stupid.net','foo@bar.love']
      end

      context 'when the address exists, but is not owned by any user' do
        before do
          EmailAddress.create!(address: 'foo@bar.love', user_id: nil)
        end

        it "adopts it and sets it to primary" do
          user.email_address = 'foo@bar.love'
          user.email_addresses.map(&:address).to_set.should == Set['primary@important.net', 'other@stupid.net', 'foo@bar.love']
          user.email_address.should == 'foo@bar.love'
        end

        it "adopts it even if the case does not match" do
          user.email_address = 'FoO@bar.love'
          user.email_addresses.map(&:address).to_set.should == Set['primary@important.net', 'other@stupid.net', 'foo@bar.love']
          user.email_address.should == 'foo@bar.love'
        end
      end
    end
  end

  describe "#api_access_token" do

    subject(:user){ create(:user) }

    it "returns the first active access token" do
      expect(user.api_access_token).to be_nil
      token = ApiAccessToken.create!(user: user)
      expect(user.api_access_token).to eq token
      token.deactivate!
      expect(user.api_access_token).to be_nil
    end
  end

end
