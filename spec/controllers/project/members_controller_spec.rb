require 'spec_helper'

describe Project::MembersController do

  let(:project) { Project.where(name: "UCSD Electric Racing").includes(:members).first! }
  let(:current_user)    { project.members.first }

  before do
    sign_in_as current_user
  end

  def valid_params
    {
      format: 'json',
      project_id: project.to_param,
    }
  end

  describe "GET index" do
    it "returns a list of users that are members of the project as json" do
      xhr :get, :index, valid_params
      response.should be_success
      # this is fucking stupid
      JSON.parse(response.body).should =~ JSON.parse(project.members.to_json)
    end

    it "shows a list of users that are members of the project" do
      get :index, project_id: project.to_param
      response.should be_success
      assigns(:members).should =~ project.members
    end
  end

  describe "POST create" do

    def valid_params
      super.merge(
        member: {
          name:  'Steve Bushebi',
          email: 'steve@bushebi.me',
          message: 'yo join this, dawg',
        }
      )
    end

    def expected_arguments
      {
        actor:   current_user,
        project: project,
        member:  {
          "name" =>  'Steve Bushebi',
          "email" => 'steve@bushebi.me',
        },
        message: 'yo join this, dawg',
      }
    end


    context "when AddMemberToProject succeeds" do
      let(:member){ User.where(name:"Ray Arvidson").first! }
      before do
        expect(AddMemberToProject).to receive(:call).with(expected_arguments).and_return(member)
      end
      it "should render the member as json with a created status" do
        post :create, valid_params
        expect(response.status).to eq 201
        expect(response.body).to eq member.to_json
      end
    end

    context "when AddMemberToProject raises an ActiveRecord::RecordNotFound error" do
      before do
        expect(AddMemberToProject).to receive(:call).with(expected_arguments).and_raise(ActiveRecord::RecordNotFound)
      end
      it "should render an error in json with an unprocessable entity status" do
        post :create, valid_params
        expect(response.status).to eq 422
        expect(response.body).to eq '{"error":"unable to find user"}'
      end

    end

    context "when AddMemberToProject raises an AddMemberToProject::UserAlreadyAMemberOfProjectError" do
      before do
        expect(AddMemberToProject).to receive(:call).with(expected_arguments).and_raise(AddMemberToProject::UserAlreadyAMemberOfProjectError.new(nil, nil))
      end

      it "should render an error in json with an unprocessable entity status" do
        post :create, valid_params
        expect(response.status).to eq 422
        expect(response.body).to eq '{"error":"user is already a member"}'
      end

    end

  end

end
