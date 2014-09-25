require 'spec_helper'

describe DailyActiveUsersWorker, :type => :request do
  let(:last_time) { Time.zone.local(2014, 2, 3) - 1.day }
  let(:time) { Time.zone.local(2014, 2, 3) }
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:billforward) { double(:billforward) }

  subject{ described_class.new }

  before do
    Time.zone = 'US/Pacific'
    subject.instance_variable_set(:@threadable, threadable)
  end

  delegate :perform!, to: :subject

  describe 'process!' do
    before do
      organization.organization_record.update_attributes(daily_active_users: 5, billforward_account_id: 'account_id', billforward_subscription_id: 'subscription_id')
    end

    it 'updates the daily active users and sends the new info to billforward' do
      expect(Threadable::Billforward).to receive(:new).with(organization: organization).and_return(billforward)
      expect(billforward).to receive(:update_member_count)

      perform! last_time, time
      drain_background_jobs!
    end
  end

end
