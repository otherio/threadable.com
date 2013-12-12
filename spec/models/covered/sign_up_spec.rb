require 'spec_helper'

describe Covered::SignUp do

  it 'creates a user' do
    attributes = {
      name: 'NAME',
      email_address: 'EMAIL_ADDRESS',
      password: 'PASSWORD',
      password_confirmation: 'PASSWORD_CONFIRMATION',
    }
    expect(covered.users).to receive(:create).with(attributes)
    described_class.call(covered, attributes)
  end

end
