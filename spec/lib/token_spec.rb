require 'spec_helper'

describe Token do

  def encode_and_decode(payload)
    token = Token.encrypt('test', payload)
    expect(token).to eq CGI.unescape(CGI.escape(token))
    expect(Token.decrypt('test', token)).to eq payload
  end

  it "should be able to encrypt and decrypt a string" do
    encode_and_decode('foobar')
  end

  it "should be able to encrypt and decrypt an integer" do
    encode_and_decode(84)
  end

  it "should be able to encrypt and decrypt complex object" do
    encode_and_decode({name:'steve', size: 34.5})
  end

  context "when the token types do not match" do
    it "should raise a Token::TypeMismatch error" do
      token = Token.encrypt('car', 'mazda')
      expect{ Token.decrypt('truck', token) }.to raise_error Token::TypeMismatch, 'car'
    end
  end

  context "when given an invalid token" do
    it "should raise a Token::Invalid error" do
      token = 'asdsasadsadsa'
      expect{ Token.decrypt('whatever', token) }.to raise_error Token::Invalid, token
    end
  end

end
