require 'spec_helper'

describe Threadable::Users, :type => :request do

  let(:users){ described_class.new(threadable) }

  describe '#find_by_email_address' do

    context "when given an email address for a user we have" do
      it 'returns that user' do
        user = users.find_by_email_address('jonathan@ucsd.example.com')
        expect(user).to be_present
        expect(user.name).to eq 'Jonathan Spray'
      end
      context 'but has weird none-ascii characters in it' do
        it 'returns that user' do
          user = users.find_by_email_address("\xEF\xBB\xBFjonathan@ucsd.example.com")
          expect(user).to be_present
          expect(user.name).to eq 'Jonathan Spray'
        end
      end
    end

    context "when given an email address for a user we do not have" do
      it 'returns nil' do
        user = users.find_by_email_address('lisa@ucsd.example.com')
        expect(user).to be_nil
      end

      it 'still works when the address is blank' do
        user = users.find_by_email_address(nil)
        expect(user).to be_nil
      end
    end

  end

end
