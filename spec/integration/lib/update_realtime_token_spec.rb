require 'spec_helper'

describe UpdateRealtimeToken, type: :request, fixtures: true do

  delegate :call, to: :described_class

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  let(:session) { {session_id: 'the_session_id'} }

  it 'stores the token in redis and returns it' do
    token = call(threadable, session)
    expect(token).to eq Digest::SHA1.hexdigest("#{session[:session_id]}:#{current_user.id}")
    redis_session = JSON.parse(Threadable.redis.hget("realtime_session-#{current_user.id}", token)).symbolize_keys
    expect(redis_session[:user_id]).to eq current_user.id
    expect(redis_session[:organization_ids]).to match_array current_user.organizations.all.map(&:id)
  end

end
