require 'spec_helper'

describe MessageWidget do

  let(:message)   { double(:message) }
  let(:arguments) { [message] }

  def html_options
    {class: 'custom_class'}
  end

    describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        message: message,
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "message custom_class",
      }
    end
  end

end
