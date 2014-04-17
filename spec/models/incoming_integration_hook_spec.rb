require 'spec_helper'

describe IncomingIntegrationHook do

  let(:attributes){ {params:{love:'it'}, provider: 'trello'} }
  let(:incoming_integration_hook) { described_class.create(attributes) }
  subject{ incoming_integration_hook }

  it { should be_persisted }
  it { should_not be_processed }
  it { should belong_to :creator }
  it { should belong_to :conversation }
  it { should belong_to :organization }
  it { should belong_to :message }
  it { should belong_to :group }
  it { should have_many :attachments }

  it { should validate_presence_of :params }
  it { should validate_presence_of :provider }
end
