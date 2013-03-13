require "spec_helper"
require 'base64'

describe UnsubscribeToken do

  describe "encrypt & decrypt" do
    it "should return a string built from the user id, the current time and some random data" do
      token = UnsubscribeToken.encrypt(22, 44)
      UnsubscribeToken.decrypt(token).should == [22, 44]

      tokens = 10.times.map{ UnsubscribeToken.encrypt(22, 44) }
      tokens.uniq.length.should == tokens.length

      tokens.map{|token| UnsubscribeToken.decrypt(token) }.should == 10.times.map{ [22, 44] }
    end
  end

end
