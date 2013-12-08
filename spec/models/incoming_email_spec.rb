require 'spec_helper'

describe IncomingEmail do

  let(:attributes){ {params:{love:'it'}} }
  subject{ described_class.create(attributes) }

  it { should be_persisted }
  it { should_not be_processed }
  it { should_not be_failed }
  it { should belong_to :creator }
  it { should belong_to :conversation }
  it { should belong_to :project }
  it { should belong_to :message }
  it { should belong_to :parent_message }
  it { should validate_presence_of :params }

  context 'when processed successfully' do
    before{ subject.processed! true }
    it { should be_persisted }
    it { should be_processed }
    it { should_not be_failed }
  end

  context 'when processed successfully' do
    before{ subject.processed! false }
    it { should be_persisted }
    it { should be_processed }
    it { should be_failed }
  end

  context 'when params is blank' do
    let(:attributes){ {params: nil} }
    it{ should have(1).errors_on(:params) }
  end

  context 'when params is present' do
    let(:attributes){ {params: {foo:'bar'}} }
    it{ should have(0).errors_on(:params) }
  end

end
