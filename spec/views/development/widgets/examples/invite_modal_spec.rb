require 'spec_helper'

describe "invite_modal example" do

  before do
    view.stub(:current_user).and_return(Covered::Project.first!.members.first!)
  end

  it_should_behave_like "a widget example"

  it "should render the invite modal and give it a project" do
    view.should_receive(:render_widget).with(:invite_modal, kind_of(Covered::Project))
    subject
  end

end
