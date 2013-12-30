require 'spec_helper'

describe IncomingEmail do

  let(:attributes){ {params:{love:'it'}} }
  let(:incoming_email) { described_class.create(attributes) }
  subject{ incoming_email }

  it { should be_persisted }
  it { should_not be_processed }
  it { should_not be_bounced }
  it { should_not be_held }
  it { should belong_to :creator }
  it { should belong_to :conversation }
  it { should belong_to :organization }
  it { should belong_to :message }
  it { should belong_to :parent_message }
  it { should have_and_belong_to_many :attachments }
  it { should have_and_belong_to_many :groups }

  it { should validate_presence_of :params }
end
