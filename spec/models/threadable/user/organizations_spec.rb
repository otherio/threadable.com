require 'spec_helper'

describe Threadable::User::Organizations do

  let(:user){ double :user, threadable: threadable }

  subject{ described_class.new user }

  it { should be_a Threadable::Organizations }
  its(:user){ should be user }
  its(:threadable){ should be threadable }
  its(:inspect){ should eq %(#<#{described_class} for_user: #{user.inspect}>) }

end
