require 'spec_helper'

describe "TrackingConcern", :type => :controller do

  describe TrackingConcern::MixpanelCookie do
    let(:cookie_name) { "mp_#{ENV.fetch('MIXPANEL_TOKEN')}_mixpanel" }
    let(:cookies) { {cookie_name => our_cookie} }
    let(:mixpanel_cookie) { TrackingConcern::MixpanelCookie.new(cookies) }

    describe '#to_hash' do

      context 'with a mixpanel cookie' do
        let(:our_cookie) { {foo: 'bar'}.to_json }

        it 'returns the cookie data' do
          expect(mixpanel_cookie.to_hash).to eq JSON.parse(our_cookie)
        end
      end

      context 'with an invalid mixpanel cookie' do
        let(:our_cookie) { 'h' }

        it 'returns an empty hash' do
          expect(mixpanel_cookie.to_hash).to eq({})
        end
      end

      context 'with no mixpanel cookie' do
        let(:cookies) { {'foo' => 'bar'} }

        it 'returns an empty hash' do
          expect(mixpanel_cookie.to_hash).to eq({})
        end
      end

    end

  end

end
