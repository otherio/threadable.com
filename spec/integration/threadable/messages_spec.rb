require 'spec_helper'

describe Threadable::Messages, :type => :request do

  let(:date) { Time.zone.local(2014,2,1).utc }
  let(:messages){ described_class.new(threadable) }
  subject{ messages }

  before do
    Time.zone = 'US/Pacific'
  end

  describe 'count_for_date' do
    let(:raceteam) { threadable.organizations.find_by_slug('raceteam') }
    let(:conversation) { raceteam.conversations.find_by_slug('welcome-to-our-threadable-organization') }

    it "counts the messages for a given date" do
      expect(raceteam.messages.count_for_date(date)).to eq 2
    end
  end
end
