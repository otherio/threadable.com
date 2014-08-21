require 'spec_helper'

describe Threadable::Users, :type => :model do

  let(:users){ described_class.new threadable }
  subject{ users }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq(threadable) }
  end


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
      it { is_expected.to be_a Threadable::User }

      describe '#user_record' do
        subject { super().user_record }
        it { is_expected.to eq(user_record) }
      end
    end

    context "when the user is not found" do
      let(:return_value){ nil }
      it { is_expected.to be_nil }
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
      it 'raises a Threadable::RecordNotFound error' do
        expect{ users.find_by_email_address!('bob@bob.com') }.to \
          raise_error(Threadable::RecordNotFound, 'unable to find user with email address: bob@bob.com')
      end
    end
    context 'when find_by_email_address returns a user' do
      let(:return_value){ user }
      subject{ users.find_by_email_address!('bob@bob.com') }
      it { is_expected.to eq user }
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
      it { is_expected.to be_a Threadable::User }

      describe '#user_record' do
        subject { super().user_record }
        it { is_expected.to eq(user_record) }
      end
    end

    context "when the user is not found" do
      let(:return_value){ nil }
      it { is_expected.to be_nil }
    end
  end


  describe '#new' do
    subject{ users.new(name: 'Steve', email_address: 'steve@me.com') }
    it{ is_expected.to be_a Threadable::User }

    describe '#name' do
      subject { super().name }
      it { is_expected.to eq('Steve') }
    end

    describe '#user_record' do
      subject { super().user_record }
      it { is_expected.not_to be_persisted }
    end
  end

  describe '#create' do
    before do
      expect_any_instance_of(Threadable::User).to receive(:track_update!)
    end

    subject{ users.create(name: 'Steve', email_address: 'steve@me.com') }
    it{ is_expected.to be_a Threadable::User }

    describe '#name' do
      subject { super().name }
      it { is_expected.to eq('Steve') }
    end

    describe '#user_record' do
      subject { super().user_record }
      it { is_expected.to be_persisted }
    end
  end

end
