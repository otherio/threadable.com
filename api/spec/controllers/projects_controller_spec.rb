require 'spec_helper'

describe ProjectsController do
  let(:user){ FactoryGirl.create(:user) }
  let(:project) { FactoryGirl.create(:project) }
  
  before(:each) do
    sign_in(user)
    project.members << user
  end

  describe "GET index" do
    it "sends projects for the current user" do
      other_project = FactoryGirl.create(:project)
      other_project.members << FactoryGirl.create(:user)

      xhr :get, :index
      result = JSON.parse(response.body)
      result[0]['name'].should == project.name
      result.length.should == 1
    end

    it "skips trackable" do
      get :index
      controller.request.env['devise.skip_trackable'].should be_true
    end
  end

  describe "GET show" do
    it "gets the project by id" do
      xhr :get, :show, {:id => project.id}
      response.should be_successful
      result = JSON.parse(response.body)
      result['name'].should == project.name
    end

    it "gets the project by slug" do
      xhr :get, :show, {:id => project.slug}
      response.should be_successful
      result = JSON.parse(response.body)
      result['name'].should == project.name
    end

    it "returns not found if the user isn't a member" do
      other_project = FactoryGirl.create(:project)
      xhr :get, :show, {:id => other_project.id}
      response.status.should == 404
    end

    it "returns not found if the project doesn't exist" do
      xhr :get, :show, {:id => "some crap that does not exist"}
      response.status.should == 404
    end
  end

  describe "GET new" do
    it "saves a new project for the current user" do
      new_project = FactoryGirl.build(:project)
      xhr :post, :create, project: new_project.attributes.slice('name', 'description')
      response.should be_success
      Project.last.name.should eq(new_project.name)
      Project.last.members[0].should eq(user)
    end
  end

  describe "PUT edit" do
    it "saves changes to an existing project" do
      xhr :put, :update, id: project.id, project: {name: "shiny new name"}
      response.should be_success
      Project.find(project.id)['name'].should == "shiny new name"
    end

    it "returns not found if attempting to edit when not a project member" do
      other_project = FactoryGirl.create(:project)
      xhr :put, :update, id: other_project.id, project: {name: "shiny new name"}
      response.status.should == 404
    end
  end

  describe "DELETE destroy" do
    it "returns forbidden if not an admin" do
      xhr :delete, :destroy, id: project.id
      response.status.should == 403
    end

    it "destroys the requested project" do
      id = project.id
      membership = project.project_memberships.where(:user_id => user.id).first
      membership.moderator = true;
      membership.save

      xhr :delete, :destroy, id: project.id
      response.should be_success
      expect { Project.find(id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
