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
      response.body.should == project.members.to_json
    end
  end

  describe "POST create" do
    describe "when given a valid user id" do
      let(:other_user){ (User.all - project.members).first }
      it "creates a new Project" do
        post :create, valid_params.merge(:member => {id: other_user.id})
        response.should be_success
        response.body.should == other_user.to_json
        project.members.reload.should include other_user
      end
    end

    describe "when given an invalid user id" do
      it "creates a new Project" do
        members = project.members.dup
        post :create, valid_params.merge(:member => {id: 3278234823748293748932})
        response.should be_not_found
        response.body.should be_blank
        project.members.reload.should == members
      end
    end

    describe "when given an email address" do
      it "creates a new Project" do
        expect{
          post :create, valid_params.merge(:member => {email: 'alf@spacecamp.org'})
        }.to change(User, :count).by(1)
        response.should be_success
        response.body.should == User.last.to_json
        project.members.reload.map(&:email).should include 'alf@spacecamp.org'
      end
    end

  end

end
