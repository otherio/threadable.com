require 'spec_helper'

describe Threadable::IncomingEmails do

  let(:incoming_emails){ described_class.new(threadable) }
  subject{ incoming_emails }

  describe '#truncate!' do
    it 'removes all incoming emails that are older than two weeks' do
      IncomingEmail.create(created_at: 1.month.ago, params: {
        "subject"=>"Old message",
      })

      IncomingEmail.create(created_at: 3.days.ago, params: {
        "subject"=>"New message",
      })

      expect(incoming_emails.all.length).to eq 2
      incoming_emails.truncate!
      expect(incoming_emails.all.length).to eq 1
    end
  end

end
