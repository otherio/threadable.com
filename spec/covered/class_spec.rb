require 'spec_helper'

describe Covered::Class do

  subject{ covered }

  let(:user){ Covered::User.first! }

  describe "new" do
    it "should take current_user, host and port as options" do
      expect{ Covered.new                                                      }.to     raise_error ArgumentError
      expect{ Covered.new host: 'example.com'                                  }.to     raise_error ArgumentError
      expect{ Covered.new host: 'example.com', port: 3000                      }.to_not raise_error
      expect{ Covered.new host: 'example.com', port: 3000, current_user_id: 14 }.to_not raise_error
      expect{ Covered.new host: 'example.com', port: 3000, current_user: user  }.to_not raise_error

      covered = Covered.new(host: 'example.com', port: 3000, current_user_id: user.id)
      expect( covered.host            ).to eq 'example.com'
      expect( covered.port            ).to eq 3000
      expect( covered.current_user_id ).to eq user.id
      expect( covered.current_user    ).to eq user

      covered = Covered.new(host: 'example.com', port: 3000, current_user: user)
      expect( covered.current_user_id ).to eq user.id
      expect( covered.current_user    ).to eq user
    end
  end

  describe "#env" do
    it "should return the expected env hash" do
      covered = Covered.new(host: 'example.com', port: 3000, current_user: user)
      expect(covered.env).to eq(
        "host"            => 'example.com',
        "port"            => 3000,
        "current_user_id" => user.id,
      )
    end
  end

  describe "#==" do
    it "should be equal if the other object is an instance of Covered and the env hashes are equal" do
      expect( covered ).to     eq Covered.new(covered.env)
      expect( covered ).to_not eq Covered.new(covered.env.merge(port: 34543))
    end
  end

  %w{operations background_jobs users projects}.each do |dependant|
    _class = Object.const_get "Covered::#{dependant.to_s.camelize}", false
    describe "##{dependant}" do
      it "should return an instance of #{_class}" do
        expect(subject.send(dependant)).to be_a _class
        expect(subject.send(dependant).covered).to eq subject
      end
    end
  end

end
