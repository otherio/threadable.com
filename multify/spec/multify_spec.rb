require 'spec_helper'

describe Multify do

  describe ".host" do

    it "should take a string and set a URI instance" do
      Multify.host.should be_nil
      Multify.host = 'http://www.google.com'
      Multify.host.should == URI.parse('http://www.google.com')
    end

    after do

    end

  end

  describe ".authenticate" do

    it "should take an email and a password and set authentication_token" do
      Multify.host = 'http://cartoons.net'

      RestClient.should_receive(:post).with('http://cartoons.net/users/sign_in', {}, {
        :AUTHORIZATION => "Basic #{::Base64.strict_encode64("boychalk@magic.pant:spongebob")}",
        :accept => :json,
      }).and_return({
        "authentication_token" => "FAKE AUTH TOKEN",
        "user" => {"id" => 42, "name" => "Jared"},
      }.to_json)

      Multify.authenticate('boychalk@magic.pant', 'spongebob').should == Multify::User.new(id: 42, name: 'Jared')
      Multify.authentication_token.should == "FAKE AUTH TOKEN"

    end

  end

end
