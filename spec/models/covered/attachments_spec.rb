require 'spec_helper'

describe Covered::Attachments do

  let(:attachments){ described_class.new(covered) }
  subject{ attachments }

  it{ should have_constant :Create }

  its(:covered){ should eq covered }

  describe 'all' do

    let :all_attachment_records do
      3.times.map do |i|
        double(:attachment_record, id: i)
      end
    end

    before do
      ::Attachment.stub_chain(:all, :reload).and_return(all_attachment_records)
    end

    it 'returns all the attachments as Covered::Attachment instances' do
      all_attachments = attachments.all
      expect(all_attachments.size).to eq 3
      all_attachments.each do |attachment|
        expect(attachment).to be_a Covered::Attachment
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

  describe 'build' do
    it 'returns an unsaved attachment' do
      attachment = attachments.build(filename: 'kitties.jpg')
      expect(attachment).to be_a Covered::Attachment
      expect(attachment.filename).to eq 'kitties.jpg'
    end
  end

  its(:inspect){ should eq "#<Covered::Attachments>" }

end
