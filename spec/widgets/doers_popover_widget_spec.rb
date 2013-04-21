require 'spec_helper'

describe DoersPopoverWidget do

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
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "doers_popover custom_class",
        widget: "doers_popover",
      }
    end
  end

end
