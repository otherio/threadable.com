require "spec_helper"
require 'base64'

describe UserSetupToken do

  it "should encrypt and decrypt a user id and path" do
    token = UserSetupToken.encrypt(22, '/foo')
    expect(UserSetupToken.decrypt(token)).to eq [22, '/foo']
  end

  it "should encrypt and decrypt a user id and organization id" do
    token = UserSetupToken.encrypt(22, 54)
    expect(UserSetupToken.decrypt(token)).to eq [22, 54]
  end

end
