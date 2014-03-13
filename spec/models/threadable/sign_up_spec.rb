require 'spec_helper'

describe Threadable::SignUp, fixtures: false do

  delegate :call, to: described_class

  def attributes
    {
      name: 'NAME',
      email_address: 'EMAIL_ADDRESS',
      password: 'PASSWORD',
      password_confirmation: 'PASSWORD_CONFIRMATION',
    }
  end

  before do
    expect(threadable.users).to receive(:create).with(attributes).and_return(user)
  end

  context "when creating the user is successful" do
    let(:user){ double(:user, id: 12321321, persisted?: true) }
    it 'returns the new user and tracks the signup' do
      expect( call(threadable, attributes) ).to be user
      assert_tracked(user.id, 'Sign up', attributes)
    end
  end

  context "when creating the user failes" do
    let(:user){ double(:user, id: 12321321, persisted?: false) }
    it 'returns the failed user and does not track the signup' do
      expect( call(threadable, attributes) ).to be user
      assert_not_tracked(user.id, 'Sign up', attributes)
    end
  end

end
