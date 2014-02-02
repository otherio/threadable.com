require 'spec_helper'

describe Threadable::Mailer do

  let(:mailer){ described_class.new threadable }
  subject{ mailer }

  its(:threadable){ should eq threadable }
  its(:default_url_options){ should eq(host: threadable.host, port: threadable.port, protocol: threadable.protocol) }

  describe 'generate' do
    it 'processes the given method name with the given args and returns the message' do
      message = double(:message)
      expect(mailer).to receive(:process).with(:example_method_name, 1, 2, 3)
      expect(mailer).to receive(:message).and_return(message)
      expect(mailer.generate(:example_method_name, 1, 2, 3)).to eq message
    end
  end

end
