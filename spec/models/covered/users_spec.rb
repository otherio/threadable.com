require 'spec_helper'

describe Covered::Users do

  let(:users){ described_class.new covered }
  subject{ users }

  its(:covered){ should == covered }


  let(:users_scope){ double :users_scope }
  let(:user_record){ double :user_record }

  describe '#find_by_email_address' do
    before do
      expect(User).to receive(:all).and_return(users_scope)
      expect(users_scope).to receive(:find_by_email_address).
        with('bob@bob.com').and_return(return_value)
    end
    subject{ users.find_by_email_address('bob@bob.com') }

    context "when the user is found" do
      let(:return_value){ user_record }
      it { should be_a Covered::User }
      its(:user_record){ should == user_record }
    end

    context "when the user is not found" do
      let(:return_value){ nil }
      it { should be_nil }
    end
  end

  describe '#find_by_email_address!' do
    let(:user){ double :user }
    before do
      expect(users).to receive(:find_by_email_address).
        with('bob@bob.com').and_return(return_value)
    end
    context 'when find_by_email_address returns nil' do
      let(:return_value){ nil }
      it 'raises a Covered::RecordNotFound error' do
        expect{ users.find_by_email_address!('bob@bob.com') }.to \
          raise_error(Covered::RecordNotFound, 'unable to find user with email address: bob@bob.com')
      end
    end
    context 'when find_by_email_address returns a user' do
      let(:return_value){ user }
      subject{ users.find_by_email_address!('bob@bob.com') }
      it { should eq user }
    end
  end

  describe '#find_by_slug' do
    let(:slug){ 'ian-baller' }
    let(:user_record){ double(:user_record) }
    before do
      expect(User).to receive(:all).and_return(users_scope)
      expect(users_scope).to receive(:where).
        with(slug:slug).and_return(users_scope)
      expect(users_scope).to receive(:first).and_return(return_value)
    end
    subject{ users.find_by_slug('ian-baller') }

    context "when the user is found" do
      let(:return_value){ user_record }
      it { should be_a Covered::User }
      its(:user_record){ should == user_record }
    end

    context "when the user is not found" do
      let(:return_value){ nil }
      it { should be_nil }
    end
  end


  describe '#new' do
    subject{ users.new(name: 'Steve', email_address: 'steve@me.com') }
    it{ should be_a Covered::User }
    its(:name){ should == 'Steve' }
    its(:user_record){ should_not be_persisted }
  end

  describe '#create' do
    before do
      expect_any_instance_of(Covered::User).to receive(:track_update!)
    end

    subject{ users.create(name: 'Steve', email_address: 'steve@me.com') }
    it{ should be_a Covered::User }
    its(:name){ should == 'Steve' }
    its(:user_record){ should be_persisted }
  end

end
