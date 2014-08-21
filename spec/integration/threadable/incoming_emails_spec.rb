require 'spec_helper'

describe Threadable::IncomingEmails, :type => :request do

  let(:incoming_emails){ described_class.new(threadable) }
  subject{ incoming_emails }

  describe '#truncate!' do
    it 'removes all successfully processed incoming emails that are older than two weeks' do
      IncomingEmail.create(
        created_at: 1.month.ago,
        params: {"subject"=>"Old delivered/bounced message"},
        processed: true,
        held: false
      )

      IncomingEmail.create(
        created_at: 1.month.ago,
        params: {"subject"=>"Old held message"},
        processed: true,
        held: true
      )

      IncomingEmail.create(
        created_at: 1.month.ago,
        params: {"subject"=>"Old unprocessed message"},
        processed: false,
        held: false
      )

      IncomingEmail.create(
        created_at: 13.days.ago,
        params: {"subject"=>"New delivered/bounced message"},
        processed: true,
        held: false
      )

      expect(incoming_emails.all.length).to eq 4
      incoming_emails.truncate!
      expect(incoming_emails.all.length).to eq 3
    end
  end

end
