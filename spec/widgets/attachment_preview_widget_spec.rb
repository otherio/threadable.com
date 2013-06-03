require 'spec_helper'

describe AttachmentPreviewWidget do

  let(:attachment){ double(:attachment) }
  let(:arguments) { [attachment] }

  def html_options
    {class: 'custom_class'}
  end

  it_should_behave_like "a widget presenter"

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        attachment: attachment,
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
