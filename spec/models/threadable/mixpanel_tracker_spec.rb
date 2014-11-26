require 'spec_helper'

describe Threadable::MixpanelTracker, :type => :model do

  let(:threadable_mixpanel_tracker){ described_class.new(threadable) }
  let(:mixpanel_tracker) { double(:mixpanel_tracker) }
  let(:people) { double(:people) }

  subject{ threadable_mixpanel_tracker }

  before do
    allow(ENV).to receive(:fetch).with('HTTP_X_FORWARDED_FOR', nil).and_return(nil)
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
        allow(threadable).to receive(:worker).and_return(true)
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
        allow(threadable).to receive(:worker).and_return(true)
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

  describe '#set_properties' do
    before do
      expect(threadable).to receive(:current_user_id).and_return(98)
    end

    it 'calls mixpanel.people.track' do
      expect(mixpanel_tracker).to receive(:people).and_return(people)
      expect(people).to receive(:set).with(98, {'foo' => 'bar'}, nil, {})
      threadable_mixpanel_tracker.set_properties('foo' => 'bar')
    end
  end

  describe '#set_properties_for_user' do
    let(:user_id) { 98 }

    it 'calls mixpanel.people.track' do
      expect(mixpanel_tracker).to receive(:people).and_return(people)
      expect(people).to receive(:set).with(98, {'foo' => 'bar'}, nil, {})
      threadable_mixpanel_tracker.set_properties_for_user(user_id, 'foo' => 'bar')
    end

    it 'puts the ignore_time flag in the flags' do
      expect(mixpanel_tracker).to receive(:people).and_return(people)
      expect(people).to receive(:set).with(98, {'foo' => 'bar'}, nil, {'$ignore_time' => true})
      threadable_mixpanel_tracker.set_properties_for_user(user_id, 'foo' => 'bar', '$ignore_time' => true)
    end

    context 'when the user ip address is in the heroku env' do
      before do
        expect(ENV).to receive(:fetch).with('HTTP_X_FORWARDED_FOR', nil).and_return('8.8.8.8, 2.2.2.2, 1.2.3.4')
      end

      context 'when the current user is the user being tracked' do
        before do
          allow(threadable).to receive(:current_user_id).and_return(98)
        end

        it 'sends the ip to mixpanel' do
          expect(mixpanel_tracker).to receive(:people).and_return(people)
          expect(people).to receive(:set).with(98, {'foo' => 'bar'}, '1.2.3.4', {})
          threadable_mixpanel_tracker.set_properties_for_user(98, 'foo' => 'bar')
        end
      end

      context 'when there is no current user' do
        before do
          allow(threadable).to receive(:current_user_id).and_return(nil)
        end

        it 'does not send the IP address' do
          expect(mixpanel_tracker).to receive(:people).and_return(people)
          expect(people).to receive(:set).with(98, {'foo' => 'bar'}, nil, {})
          threadable_mixpanel_tracker.set_properties_for_user(98, 'foo' => 'bar')
        end
      end

      context 'when the current user does not match the user being tracked' do
        before do
          allow(threadable).to receive(:current_user_id).and_return(102)
        end

        it 'does not send the ip address' do
          expect(mixpanel_tracker).to receive(:people).and_return(people)
          expect(people).to receive(:set).with(98, {'foo' => 'bar'}, nil, {})
          threadable_mixpanel_tracker.set_properties_for_user(98, 'foo' => 'bar')
        end
      end
    end

    context 'when mixpanel fails' do
      known_errors = [
        Errno::ECONNRESET,
        Mixpanel::ConnectionError,
        OpenSSL::SSL::SSLError,
        Net::ReadTimeout,
      ]

      before do
        allow(mixpanel_tracker).to receive(:people).and_return(people)
      end

      known_errors.each do |known_error|
        it "retries twice for #{known_error.to_s}" do
          expect(people).to receive(:set).twice.and_raise(known_error)
          expect(people).to receive(:set).once.and_return(true)
          threadable_mixpanel_tracker.set_properties_for_user(user_id, 'foo' => 'bar')
        end

        it "continues if #{known_error.to_s} keeps occurring" do
          expect(people).to receive(:set).exactly(3).times.and_raise(known_error)
          expect{ threadable_mixpanel_tracker.set_properties_for_user(user_id, 'foo' => 'bar') }.to_not raise_error
        end
      end

      it 'raises an unknown exception' do
        expect(people).to receive(:set).and_raise(Exception)
        expect{ threadable_mixpanel_tracker.set_properties_for_user(user_id, 'foo' => 'bar') }.to raise_error Exception
      end

    end
  end


  describe 'track_user_change' do
    let(:created_at){ double(:created_at, iso8601: "2013-12-03T16:24:37-08:00") }
    let(:user) do
      double(:user,
        id: 833,
        name: 'steve',
        email_address: 'steve@steve.io',
        created_at: created_at,
        organization_owner: false,
        munge_reply_to?: false,
        web_enabled?: true,
    )
    end

    it 'calls Mixpanel::Tracker#people.set' do
      expect(mixpanel_tracker).to receive(:people).and_return(people)
      expect(people).to receive(:set).with(833, {
        '$user_id'       => 833,
        '$name'          => 'steve',
        '$email'         => 'steve@steve.io',
        '$created'       => "2013-12-03T16:24:37-08:00",
        'Owner'          => false,
        'Web Enabled'    => true,
        'Munge Reply-to' => false,
      }, nil, {})
      threadable_mixpanel_tracker.track_user_change(user)
    end
  end

  describe '#refresh_user_record' do
    let(:created_at){ double(:created_at, iso8601: "2013-12-03T16:24:37-08:00") }
    let(:user) do
      double(:user,
        id: 833,
        name: 'steve',
        email_address: 'steve@steve.io',
        created_at: created_at,
        organization_owner: false,
        munge_reply_to?: false,
        web_enabled?: true,
        messages: double(:messages, count: 25)
    )
    end

    it 'calls Mixpanel::Tracker#people.set, and refreshes all counters' do
      expect(mixpanel_tracker).to receive(:people).and_return(people)
      expect(people).to receive(:set).with(833, {
        '$user_id'          => 833,
        '$name'             => 'steve',
        '$email'            => 'steve@steve.io',
        '$created'          => "2013-12-03T16:24:37-08:00",
        'Owner'             => false,
        'Web Enabled'       => true,
        'Munge Reply-to'    => false,
        'Composed Messages' => 25,
      }, nil, {'$ignore_time' => true})
      threadable_mixpanel_tracker.refresh_user_record(user)
    end
  end

  describe '#increment_for_user' do
    it 'calls Mixpanel::Tracker#people.increment' do
      expect(mixpanel_tracker).to receive(:people).and_return(people)
      expect(people).to receive(:increment).with(98, 'foo' => 1)
      threadable_mixpanel_tracker.increment_for_user(98, 'foo' => 1)
    end
  end

  describe '#increment' do
    before do
      expect(threadable).to receive(:current_user_id).and_return(98)
    end

    it 'calls Mixpanel::Tracker#people.increment, but looks up the tracking id' do
      expect(mixpanel_tracker).to receive(:people).and_return(people)
      expect(people).to receive(:increment).with(98, 'foo' => 1)
      threadable_mixpanel_tracker.increment('foo' => 1)
    end
  end

end
