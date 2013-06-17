require 'spec_helper'

describe AttachmentPreviewWidget do

  let(:attachment) do
    double(:attachment,
      url: 'http://example.com/32h4j32hj432hkj',
      filename: 'foo.gif',
      mimetype: 'image/gif',
    )
  end
  let(:arguments) { [attachment] }

  def html_options
    {class: 'custom_class'}
  end

  it_should_behave_like "a widget presenter"

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block:           nil,
        presenter:       presenter,
        attachment:      attachment,
        href:            'http://example.com/32h4j32hj432hkj',
        filename:        'foo.gif',
        mimetype:        'image/gif',
        preview_src_url: 'http://example.com/32h4j32hj432hkj/convert?fit=crop&h=42&w=43',
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "attachment_preview custom_class",
        widget: "attachment_preview",
      }
    end
  end

end
