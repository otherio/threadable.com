require 'spec_helper'

describe "attachment_preview" do

  let(:attachment){
    double(:attachment, url: 'http://example.com/thing.jpeg', filename: 'thing.jpeg')
  }

  def locals
    {attachment: attachment}
  end


  context "when the attachment is an image" do
    before do
      attachment.stub(:mimetype).and_return('image/jpeg')
    end
    it "should have an img tag" do
      img = html.css('img').first
      img[:src].should == "#{attachment.url}/convert?h=43&w=43&fit=crop"
    end
  end

  context "when the attachment is an image" do
    before do
      attachment.stub(:mimetype).and_return('microsoft/crap')
    end
    it "should have an img tag" do
      html.css('i.icon-file').should be_present
    end
  end

end
