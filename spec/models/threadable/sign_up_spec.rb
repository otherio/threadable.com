require 'spec_helper'

describe Threadable::SignUp do

  it 'creates a user' do
    attributes = {
      name: 'NAME',
      email_address: 'EMAIL_ADDRESS',
      password: 'PASSWORD',
      password_confirmation: 'PASSWORD_CONFIRMATION',
    }
    expect(threadable.users).to receive(:create).with(attributes)
    described_class.call(threadable, attributes)
  end

end
