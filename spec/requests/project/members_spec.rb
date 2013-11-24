require 'spec_helper'

describe "project members" do

  before{ sign_in_as 'alice@ucsd.covered.io' }
  let(:project){ current_user.projects.find_by_slug! 'raceteam' }

  describe "reading members of a project" do
    it "should work" do
      get project_members_url(project, format: :json)
      expect(response).to be_success
      expect(response.body).to eq project.members.all.to_json
    end
  end

  describe "adding a member to a project" do
    let(:other_user){ covered.users.find_by_email_address('marcus@sfhealth.example.com') }
    it "should work" do
      post project_members_url(project, format: :json), {member: { id: other_user.id }}
      expect(response).to be_success
      expect(response.body).to eq project.members.find_by_user_id!(other_user.id).to_json
    end
  end

  describe "removing a member from a project" do
    let(:member){ project.members.all.last }
    it "should work" do
      delete project_member_url(project, member, format: :json)
      expect(response).to be_success
      expect(project.members).to_not include member
      expect(response.body).to be_blank
    end
  end

end
