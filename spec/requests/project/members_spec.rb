require 'spec_helper'

describe "project members", driver: :rack_test do

  let(:project) { Project.where(name: "UCSD Electric Racing").includes(:members).first! }
  let(:user)    { project.members.first }

  before do
    sign_in_as user
  end

  describe "reading members of a project" do
    it "should work" do
      get project_members_url(project, format: :json)
      response.should be_success
      response.body.should == project.members.reload.to_json
    end
  end

  describe "adding a member to a project" do
    let(:other_user){ (User.all - project.members).first }
    it "should work" do
      post project_members_url(project, format: :json), {member: { id: other_user.id }}
      response.should be_success
      project.members.reload.should include other_user
      response.body.should == other_user.to_json
    end
  end

  describe "removing a member from a project" do
    let(:member){ project.members.last }
    it "should work" do
      delete project_member_url(project, member, format: :json)
      response.should be_success
      project.members.reload.should_not include member
      response.body.should be_blank
    end
  end

end
