require 'spec_helper'

describe Covered::SignUp do

  it 'creates a user' do
    options = {
      name: 'NAME',
      email_address: 'EMAIL_ADDRESS',
      password: 'PASSWORD',
      password_confirmation: 'PASSWORD_CONFIRMATION',
    }
    expect(covered.users).to receive(:create).with(options)
    described_class.call options.merge(covered: covered)
  end
end
