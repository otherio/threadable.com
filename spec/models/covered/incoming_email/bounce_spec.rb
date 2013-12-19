require 'spec_helper'

describe Covered::IncomingEmail::Bounce do

  let(:incoming_email) do
    double(:incoming_email,
      covered: covered,
    )
  end

  def call!
    described_class.call(incoming_email)
  end

  it 'sends a held message notice and marks the incoming email as held' do
    expect(incoming_email).to receive(:bounced!)
    call!
  end

end
