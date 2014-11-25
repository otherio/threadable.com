require 'spec_helper'

describe Threadable::User::Messages, :type => :request do

  describe 'scope' do
    let(:user) { threadable.users.find_by_email_address('alice@ucsd.example.com') }

    it 'is scoped to the user' do
      expect(user.messages.all.map{ |m| m.creator.id }.uniq).to eq [user.id]
    end
  end

end
