require 'spec_helper'

describe Covered::Attachment do

  let :attachment_record do
    double(:attachment_record,
      id: 4500,
      url: 'http://aws.com/kittens.gif',
    )
  end

  let(:attachment){ described_class.new(covered, attachment_record) }
  subject{ attachment }

  it{ should delegate(:id        ).to(:attachment_record) }
  it{ should delegate(:url       ).to(:attachment_record) }
  it{ should delegate(:filename  ).to(:attachment_record) }
  it{ should delegate(:mimetype  ).to(:attachment_record) }
  it{ should delegate(:size      ).to(:attachment_record) }
  it{ should delegate(:content   ).to(:attachment_record) }
  it{ should delegate(:writeable?).to(:attachment_record) }
  it{ should delegate(:created_at).to(:attachment_record) }
  it{ should delegate(:updated_at).to(:attachment_record) }

  its(:covered){ should eq covered }

  its(:attachment_record){ should eq attachment_record }

  its(:inspect){ should eq %(#<Covered::Attachment attachment_id: 4500 url: "http://aws.com/kittens.gif">) }

end
