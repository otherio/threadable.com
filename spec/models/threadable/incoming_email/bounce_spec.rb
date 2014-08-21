require 'spec_helper'

describe Threadable::IncomingEmail::Bounce, :type => :model do

  let(:incoming_email) do
    double(:incoming_email,
      threadable: threadable,
    )
  end

  delegate :call, to: described_class

  it 'marks the incoming email as bounced and sends a DSN' do
    expect(incoming_email).to receive(:bounced!)
    expect(threadable.emails).to receive(:send_email).with(:message_bounced_dsn, incoming_email)

    call incoming_email
  end

end
