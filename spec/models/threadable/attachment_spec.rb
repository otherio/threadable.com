require 'spec_helper'

describe Threadable::Attachment, :type => :model do

  let :attachment_record do
    double(:attachment_record,
      id: 4500,
      url: 'http://aws.com/kittens.gif',
    )
  end

  let(:attachment){ described_class.new(threadable, attachment_record) }
  subject{ attachment }

  it{ is_expected.to delegate(:id        ).to(:attachment_record) }
  it{ is_expected.to delegate(:url       ).to(:attachment_record) }
  it{ is_expected.to delegate(:filename  ).to(:attachment_record) }
  it{ is_expected.to delegate(:mimetype  ).to(:attachment_record) }
  it{ is_expected.to delegate(:size      ).to(:attachment_record) }
  it{ is_expected.to delegate(:content   ).to(:attachment_record) }
  it{ is_expected.to delegate(:writeable?).to(:attachment_record) }
  it{ is_expected.to delegate(:created_at).to(:attachment_record) }
  it{ is_expected.to delegate(:updated_at).to(:attachment_record) }
  it{ is_expected.to delegate(:content_id).to(:attachment_record) }
  it{ is_expected.to delegate(:inline?   ).to(:attachment_record) }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable }
  end

  describe '#attachment_record' do
    subject { super().attachment_record }
    it { is_expected.to eq attachment_record }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq %(#<Threadable::Attachment attachment_id: 4500 url: "http://aws.com/kittens.gif">) }
  end

end
