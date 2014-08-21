require 'spec_helper'

describe Threadable::Mailer, :type => :model do

  let(:mailer){ described_class.new threadable }
  subject{ mailer }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable }
  end

  describe '#default_url_options' do
    subject { super().default_url_options }
    it { is_expected.to eq(host: threadable.host, port: threadable.port, protocol: threadable.protocol) }
  end

  describe 'generate' do
    it 'processes the given method name with the given args and returns the message' do
      message = double(:message)
      expect(mailer).to receive(:process).with(:example_method_name, 1, 2, 3)
      expect(mailer).to receive(:message).and_return(message)
      expect(mailer.generate(:example_method_name, 1, 2, 3)).to eq message
    end
  end

end
