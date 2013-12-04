require 'spec_helper'

describe Covered::MixpanelTracker do

  let(:covered_mixpanel_tracker){ described_class.new(covered) }
  let(:mixpanel_tracker) { double(:mixpanel_tracker) }

  subject{ covered_mixpanel_tracker }

  before do
    expect(ENV).to receive(:fetch).with('MIXPANEL_TOKEN').and_return('FAKE TOKEN')
    expect(Mixpanel::Tracker).to receive(:new).with('FAKE TOKEN').and_return(mixpanel_tracker)
  end

  describe 'track' do
    it 'calls Mixpanel::Tracker#track' do
      expect(covered).to receive(:current_user_id).and_return(98)
      expect(mixpanel_tracker).to receive(:track).with(98, 'foo')
      covered_mixpanel_tracker.track('foo')
    end
  end


  describe 'track_user_change' do
    let(:created_at){ double(:created_at, iso8601: "2013-12-03T16:24:37-08:00") }
    let(:user){ double(:user, id: 833, name: 'steve', email_address: 'steve@steve.io', created_at: created_at) }
    let(:people){ double :people }
    it 'calls Mixpanel::Tracker#people.set' do
      expect(mixpanel_tracker).to receive(:people).and_return(people)
      expect(people).to receive(:set).with(833,
        '$name'    => 'steve',
        '$email'   => 'steve@steve.io',
        '$created' => "2013-12-03T16:24:37-08:00",
      )
      covered_mixpanel_tracker.track_user_change(user)
    end
  end

end
