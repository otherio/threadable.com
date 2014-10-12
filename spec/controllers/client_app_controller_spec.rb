require 'spec_helper'

describe ClientAppController, type: :controller, fixtures: true do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }

  before do
    request.accept = 'text/html'
  end

  when_not_signed_in do
    describe '#show' do
      it 'redirects to sign in' do
        get :show, path: 'raceteam/my/conversations'
        expect(response.status).to eq 302
      end
    end
  end

  when_signed_in_as 'alice@ucsd.example.com' do
    describe '#show' do
      it 'does not allow xhr' do
        xhr :get, :show, path: 'raceteam/my/conversations'
        expect(response.status).to eq 404
      end

      it 'stores a new session in redis' do
        get :show, path: 'raceteam/my/conversations'

        expect(response.status).to eq 200
        token = assigns(:realtime_token)
        expect(token).to eq Digest::SHA1.hexdigest("#{session[:session_id]}:#{current_user.id}")
        expect(assigns(:realtime_url)).to be
        session = JSON.parse(Threadable.redis.hget("realtime_session-#{current_user.id}", token)).symbolize_keys
        expect(session[:user_id]).to eq current_user.id
        expect(session[:organization_ids]).to match_array current_user.organizations.all.map(&:id)
      end
    end
  end
end
