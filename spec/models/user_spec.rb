require 'spec_helper'

describe User do

  it { should have_many :email_addresses }
  it { should have_many :project_memberships }
  it { should have_many :projects }
  it { should have_many :messages }
  it { should have_many :conversations }
  it { should have_and_belong_to_many :tasks }

  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  # it { should validate_confirmation_of :password } # this is only when confirmed

  it { should allow_mass_assignment_of :name }
  it { should allow_mass_assignment_of :email }
  it { should allow_mass_assignment_of :slug }
  it { should allow_mass_assignment_of :password }
  it { should allow_mass_assignment_of :password_confirmation }
  it { should allow_mass_assignment_of :remember_me }
  it { should allow_mass_assignment_of :tasks }
  it { should allow_mass_assignment_of :avatar_url }
  it { should allow_mass_assignment_of :provider }
  it { should allow_mass_assignment_of :uid }

  def build_user_with_password password
    FactoryGirl.build(:user, password: password, password_confirmation: password)
  end

  it "should validate uniqness of email" do
    existing_email = User.last.email
    user = FactoryGirl.build(:user, email: existing_email)
    user.should_not be_valid
    user.errors.messages[:email].should be_present
    user.errors.messages[:email].should include "has already been taken"
  end

  context "when confirmed" do
    def build_user_with_password password
      super.tap{|user| user.confirmed_at = Time.now }
    end
    it "should validate the length of password" do
      build_user_with_password("").should_not be_valid
      build_user_with_password("boo").should_not be_valid
      build_user_with_password("booyakasha").should be_valid
    end

    it "should validate that password and password_confirmation match" do
      FactoryGirl.build(:user,
        password: 'abcdefgh',
        password_confirmation: 'ijklmnop',
        confirmed_at: Time.now
      ).should_not be_valid

      FactoryGirl.build(:user,
        password: 'abcdefgh',
        password_confirmation: 'abcdefgh',
        confirmed_at: Time.now
      ).should be_valid
    end
  end

  describe "#find_by_email" do
    let(:user){ FactoryGirl.create(:user) }
    it "should find the user by the given email through the email_addresses relation" do
      User.find_by_email(user.email).should == user
    end
  end

  it "should have a valid factory" do
    FactoryGirl.build(:user).should be_valid
  end

  it "should include an auth token" do
    FactoryGirl.create(:user).authentication_token.should be_true
  end

  it "should use the gravatar as the default avatar when none is supplied" do
    user = FactoryGirl.create(:user, email: 'foo@example.com', avatar_url: nil)
    user.avatar_url.should == 'http://gravatar.com/avatar/b48def645758b95537d4424c84d1a9ff.png?s=48&d=retro'
  end

  context do

    let(:user){ User.new }

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

  describe "password_required?" do
    context "when confirmed" do
      let(:user){ User.where('confirmed_at IS NOT NULL').first }
      it "should be true" do
        user.send(:password_required?).should be_true
      end
    end
    context "when not confirmed" do
      let(:user){ FactoryGirl.create(:user, confirmed_at: nil) }
      it "should be false" do
        user.send(:password_required?).should be_false
      end
    end
    context "when @password_required is truthy" do
      let(:user){ User.new }
      before{ user.password_required = 42 }
      it "should be true" do
        user.send(:password_required?).should be_true
      end
    end
    context "when @password_required is false" do
      let(:user){ User.new }
      before{ user.password_required = false }
      it "should be true" do
        user.send(:password_required?).should be_false
      end
    end
  end

end
