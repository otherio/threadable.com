require 'spec_helper'

describe IncomingEmail, :type => :model do

  let(:attributes){ {params:{love:'it'}} }
  let(:incoming_email) { described_class.create(attributes) }
  subject{ incoming_email }

  it { is_expected.to be_persisted }
  it { is_expected.not_to be_processed }
  it { is_expected.not_to be_bounced }
  it { is_expected.not_to be_held }
  it { is_expected.to belong_to :creator }
  it { is_expected.to belong_to :conversation }
  it { is_expected.to belong_to :organization }
  it { is_expected.to belong_to :message }
  it { is_expected.to belong_to :parent_message }
  it { is_expected.to have_and_belong_to_many :attachments }
  it { is_expected.to have_and_belong_to_many :groups }

  it { is_expected.to validate_presence_of :params }
end
