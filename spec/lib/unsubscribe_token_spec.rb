require "spec_helper"
require 'base64'

describe UnsubscribeToken do

  it "should encrypt and decrypt a user id" do
    token = UnsubscribeToken.encrypt(22)
    expect(UnsubscribeToken.decrypt(token)).to eq 22
  end

end
