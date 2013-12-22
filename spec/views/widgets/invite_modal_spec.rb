require 'spec_helper'

describe "invite_modal" do

  let(:organization){ Factories.build(:organization) }

  def locals
    {organization: organization}
  end

  it "should have a form that posts to the organization invites url" do
    form = html.css('form').first
    form[:action].should == organization_members_url(organization)
    form[:method].should == 'post'
  end

end
