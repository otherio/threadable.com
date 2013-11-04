require 'spec_helper'

describe Covered, :type => :covered do

  subject{ covered }

  let(:user){ Covered::User.first! }

  describe "new" do
    it "should curry to Covered::Class.new" do
      env = {}
      expect(Covered::Class).to receive(:new).with(env)
      Covered.new(env)
    end
  end


  describe "config" do
    it "should return the config for the given name" do
      expect(Covered.config('database')).to be_a Hash
    end
  end

end
