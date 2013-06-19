require 'spec_helper'

describe "attachment_preview" do

  def locals
    {
      href: 'http://aws.example.com/images/foo.gif',
      filename: 'foo.gif',
      mimetype: 'image/gif',
      preview_src_url: '/images/foo.gif',
    }
  end

  let(:link     ){ html.css('a').first }
  let(:img      ){ link.css('img').first }
  let(:file_icon){ link.css('i.icon-file').first }

  context "when the attachment is an image" do
    it "should have an img tag" do
      expect(link        ).to be_present
      expect(img         ).to be_present
      expect(file_icon   ).to be_nil
      expect(link[:href] ).to eq locals[:href]
      expect(link[:title]).to eq locals[:filename]
      expect(img[:src]   ).to eq locals[:preview_src_url]
    end
  end

  context "when the attachment is not an image" do
    def locals
      super.merge(mimetype: 'application/json')
    end
    it "should have an img tag" do
      expect(link        ).to be_present
      expect(img         ).to be_nil
      expect(file_icon   ).to be_present
      expect(link[:href] ).to eq locals[:href]
      expect(link[:title]).to eq locals[:filename]
    end
  end

end
