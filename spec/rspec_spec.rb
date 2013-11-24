require 'spec_helper'

describe 'rspec configuration' do

  def transaction_should_not_be_open!
    expect(ActiveRecord::Base.connection.transaction_open?).to be_false
  rescue
    binding.pry
    raise
  end

  def transaction_should_be_open!
    expect(ActiveRecord::Base.connection.transaction_open?).to be_true
  rescue
    binding.pry
    raise
  end

  def fixtures_should_be_loaded!
    User.count.should > 0
    Project.count.should > 0
  end

  def fixtures_should_not_be_loaded!
    User.count.should == 0
    Project.count.should == 0
  end

  3.times do
    describe 'useing fixtures and a test transaction' do
      it "should have fixture data and be in a test transaction" do
        transaction_should_be_open!
        fixtures_should_be_loaded!
        User.delete_all
      end
    end

    describe 'useing fixtures without a test transaction', transaction: false do
      it "should have fixture data but not be in a test transaction" do
        transaction_should_not_be_open!
        fixtures_should_be_loaded!
        User.delete_all
      end
    end

    describe 'not useing fixtures or a test transaction', fixtures: false, transaction: false do
      it "should not have fixture and not be in a test transaction" do
        transaction_should_not_be_open!
        fixtures_should_not_be_loaded!
        User.delete_all
      end
    end

    describe 'not useing fixtures but using a test transaction', fixtures: false do
      it "should not have fixture data but be in a test transaction" do
        transaction_should_be_open!
        fixtures_should_not_be_loaded!
        User.delete_all
      end
    end
  end

end
