require 'spec_helper'

describe Threadable::MixpanelTracker do

  let(:threadable_mixpanel_tracker){ described_class.new(threadable) }
  let(:mixpanel_tracker) { double(:mixpanel_tracker) }

  subject{ threadable_mixpanel_tracker }

  before do
    expect(ENV).to receive(:fetch).with('MIXPANEL_TOKEN').and_return('FAKE TOKEN')
    expect(Mixpanel::Tracker).to receive(:new).with('FAKE TOKEN').and_return(mixpanel_tracker)
  end

  describe 'track' do
    before do
      expect(threadable).to receive(:current_user_id).and_return(98)
    end
    context 'when running outside a worker' do
      it 'calls Mixpanel::Tracker#track' do
        expect(mixpanel_tracker).to receive(:track).with(98, "An event", {via: 'web', things: 'are good'})
        threadable_mixpanel_tracker.track("An event", {things: 'are good'})
      end
    end

    context 'when running in a worker' do
      before do
        threadable.stub(:worker).and_return(true)
      end

      it 'calls Mixpanel::Tracker#track' do
        expect(mixpanel_tracker).to receive(:track).with(98, "An event", {via: 'email', things: 'are good'})
        threadable_mixpanel_tracker.track("An event", {things: 'are good'})
      end
    end
  end

  describe 'track_for_user' do
    let(:user_id) { 98 }
    context 'when running outside a worker' do
      it 'calls Mixpanel::Tracker#track' do
        expect(mixpanel_tracker).to receive(:track).with(98, "An event", {via: 'web', things: 'are good'})
        threadable_mixpanel_tracker.track_for_user(user_id, "An event", {things: 'are good'})
      end
    end

    context 'when running in a worker' do
      before do
        threadable.stub(:worker).and_return(true)
      end

      it 'calls Mixpanel::Tracker#track' do
        expect(mixpanel_tracker).to receive(:track).with(98, "An event", {via: 'email', things: 'are good'})
        threadable_mixpanel_tracker.track_for_user(user_id, "An event", {things: 'are good'})
      end
    end

    context 'when mixpanel fails' do
      known_errors = [
        Errno::ECONNRESET,
        Mixpanel::ConnectionError,
        OpenSSL::SSL::SSLError,
        Net::ReadTimeout,
      ]

      known_errors.each do |known_error|
        it "retries twice for #{known_error.to_s}" do
          expect(mixpanel_tracker).to receive(:track).twice.and_raise(known_error)
          expect(mixpanel_tracker).to receive(:track).once.and_return(true)
          threadable_mixpanel_tracker.track_for_user(user_id, "An event", {things: 'are good'})
        end

        it "continues if #{known_error.to_s} keeps occurring" do
          expect(mixpanel_tracker).to receive(:track).exactly(3).times.and_raise(known_error)
          expect{ threadable_mixpanel_tracker.track_for_user(user_id, "An event", {things: 'are good'}) }.to_not raise_error
        end
      end

      it 'raises an unknown exception' do
        expect(mixpanel_tracker).to receive(:track).and_raise(Exception)
        expect{ threadable_mixpanel_tracker.track_for_user(user_id, "An event", {things: 'are good'}) }.to raise_error Exception
      end

    end
  end


  describe 'track_user_change' do
    let(:created_at){ double(:created_at, iso8601: "2013-12-03T16:24:37-08:00") }
    let(:user){ double(:user, id: 833, name: 'steve', email_address: 'steve@steve.io', created_at: created_at) }
    let(:people){ double :people }
    it 'calls Mixpanel::Tracker#people.set' do
      expect(mixpanel_tracker).to receive(:people).and_return(people)
      expect(people).to receive(:set).with(833,
        '$user_id' => user.id,
        '$name'    => 'steve',
        '$email'   => 'steve@steve.io',
        '$created' => "2013-12-03T16:24:37-08:00",
      )
      threadable_mixpanel_tracker.track_user_change(user)
    end
  end

end
