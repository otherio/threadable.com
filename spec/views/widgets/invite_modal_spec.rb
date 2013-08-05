require 'spec_helper'

describe "invite_modal" do

  let(:project){ Project.last }

  def locals
    {
      project: project
    }
  end

  it "should have a form that posts to the project invites url" do
    form = html.css('form').first
    form[:action].should == project_members_url(project)
    form[:method].should == 'post'
  end

end
