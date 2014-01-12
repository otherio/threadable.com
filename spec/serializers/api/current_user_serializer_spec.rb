require 'spec_helper'

describe Api::CurrentUserSerializer do

  let(:alice) { covered.users.find_by_email_address!('alice@ucsd.example.com') }
  let(:marcus){ covered.users.find_by_email_address!('marcus@sfhealth.example.com') }

  let(:payload){ current_user }

  context 'when signed in as alice' do
    before { covered.current_user = alice }
    it do
      should eq(
        user: {
          id:            'current',
          user_id:       alice.user_id,
          param:         alice.to_param,
          name:          alice.name,
          email_address: alice.email_address.to_s,
          slug:          alice.slug,
          avatar_url:    alice.avatar_url,
        }
      )
    end
  end

  context 'when signed in as marcus' do
    before { covered.current_user = marcus }
    it do
      should eq(
        user: {
          id:            'current',
          user_id:       marcus.user_id,
          param:         marcus.to_param,
          name:          marcus.name,
          email_address: marcus.email_address.to_s,
          slug:          marcus.slug,
          avatar_url:    marcus.avatar_url,
        }
      )
    end
  end


end
