require 'spec_helper'

describe Attachment, type: :model, fixtures: false do

  let(:mimetype){ "text/plain" }

  let(:attributes) do
    {
      url:       "https://www.filepicker.io/api/file/RAVjsBKtRpqgzM6wvdaH",
      filename:  "some.txt",
      mimetype:  mimetype,
      size:      35,
      writeable: false,
    }
  end

  let(:attachment){ described_class.new(attributes) }

  describe "#binary?" do
    subject { attachment.binary? }
    context "when the mimetype is 'text/plain'" do
      let(:mimetype){ "text/plain" }
      it { is_expected.to be_falsey }
    end
    context "when the mimetype is 'image/jpeg'" do
      let(:mimetype){ "image/jpeg" }
      it { is_expected.to be_truthy }
    end

  end

  describe "#content" do
    it "should call HTTParty.get(url)" do
      expect(HTTParty).to receive(:get).once.with(attributes[:url], parser: Attachment::FakeParser).and_return("FAKE CONTENT")
      expect(attachment.content).to eq "FAKE CONTENT"
      expect(attachment.content).to eq "FAKE CONTENT"
    end
  end

end
