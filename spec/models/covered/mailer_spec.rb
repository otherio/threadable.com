require 'spec_helper'

describe Covered::Mailer do

  let(:mailer){ described_class.new covered }
  subject{ mailer }

  its(:covered){ should eq covered }
  its(:default_url_options){ should eq(host: covered.host, port: covered.port, protocol: covered.protocol) }

  describe 'generate' do
    it 'processes the given method name with the given args and returns the message' do
      message = double(:message)
      expect(mailer).to receive(:process).with(:example_method_name, 1, 2, 3)
      expect(mailer).to receive(:message).and_return(message)
      expect(mailer.generate(:example_method_name, 1, 2, 3)).to eq message
    end
  end

end
