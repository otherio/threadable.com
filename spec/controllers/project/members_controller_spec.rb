require 'spec_helper'

describe Project::MembersController do

  let(:project) { Project.find_by_name("UCSD Electric Racing", include: :members) }
  let(:user)    { project.members.first }

  before do
    sign_in user
  end

  def valid_params
    {
      format: 'json',
      project_id: project.to_param,
    }
  end

  describe "GET index" do
    it "returns a list of users that are members of the project" do
      xhr :get, :index, valid_params
      response.should be_success
      # this is fucking stupid
      JSON.parse(response.body).should =~ JSON.parse(project.members.to_json)
    end
  end

  describe "POST create" do
    describe "when given a valid user id" do
      let(:other_user){ (User.all - project.members).first }
      it "creates a new project membership" do
        post :create, valid_params.merge(:member => {id: other_user.id})
        response.should be_success
        response.body.should == other_user.to_json
        project.members.reload.should include other_user
      end
    end

    describe "when given an invalid user id" do
      it "does not create a new project membership" do
        members = project.members.dup
        post :create, valid_params.merge(:member => {id: 'jon-varvatos'})
        response.should be_not_found
        response.body.should be_blank
        project.members.reload.should =~ members
      end
    end

  end

end
