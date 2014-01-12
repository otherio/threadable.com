require 'spec_helper'

describe Api::CurrentUserController do

  let(:alice){ covered.users.find_by_email_address!('alice@ucsd.example.com') }
  let(:bob)  { covered.users.find_by_email_address!('bob@ucsd.example.com') }

   when_not_signed_in do

    describe 'show' do
      it 'renders a blank current user as json' do
        xhr :get, :show, format: :json
        expect(response.status).to eq 200
        expect(response.body).to eq(
          {
            user: {
              id:            'current',
              user_id:       nil,
              param:         nil,
              name:          nil,
              email_address: nil,
              slug:          nil,
              avatar_url:    nil,
            }
          }.to_json
        )
      end
    end

  end

  when_signed_in_as 'bob@ucsd.example.com' do
    describe 'show' do
      it 'renders bob as json' do
        xhr :get, :show, format: :json
        expect(response.status).to eq 200
        expect(response.body).to eq(
          {
            user: {
              id:            'current',
              user_id:       bob.user_id,
              param:         bob.to_param,
              name:          bob.name,
              email_address: bob.email_address.to_s,
              slug:          bob.slug,
              avatar_url:    bob.avatar_url,
            }
          }.to_json
        )
      end
    end
  end

  when_signed_in_as 'alice@ucsd.example.com' do
    describe 'show' do
      it 'renders alice as json' do
        xhr :get, :show, format: :json
        expect(response.status).to eq 200
        expect(response.body).to eq(
          {
            user: {
              id:            'current',
              user_id:       alice.user_id,
              param:         alice.to_param,
              name:          alice.name,
              email_address: alice.email_address.to_s,
              slug:          alice.slug,
              avatar_url:    alice.avatar_url,
            }
          }.to_json
        )
      end
    end
  end

end
