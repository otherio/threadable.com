require 'spec_helper'

describe InviteModalWidget do

  let(:organization)   { double(:organization) }
  let(:arguments) { [organization] }

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
        organization: organization,
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "invite_modal modal hide fade custom_class",
        widget: "invite_modal",
      }
    end
  end

end
