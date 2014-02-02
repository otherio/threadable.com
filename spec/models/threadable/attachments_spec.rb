require 'spec_helper'

describe Threadable::Attachments do

  let(:attachments){ described_class.new(threadable) }
  subject{ attachments }

  it{ should have_constant :Create }

  its(:threadable){ should eq threadable }

  describe 'all' do

    let :all_attachment_records do
      3.times.map do |i|
        double(:attachment_record, id: i)
      end
    end

    before do
      ::Attachment.stub all: all_attachment_records
    end

    it 'returns all the attachments as Threadable::Attachment instances' do
      all_attachments = attachments.all
      expect(all_attachments.size).to eq 3
      all_attachments.each do |attachment|
        expect(attachment).to be_a Threadable::Attachment
        expect(all_attachment_records).to include attachment.attachment_record
      end
    end
  end

  describe 'count' do
    before do
      ::Attachment.stub_chain(:all, :count).and_return(45)
    end
    it 'returns a count all the attachments' do
      expect(attachments.count).to eq 45
    end
  end

  its(:inspect){ should eq "#<Threadable::Attachments>" }

end
