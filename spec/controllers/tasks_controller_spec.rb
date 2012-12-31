require 'spec_helper'

describe TasksController do
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task) }

  before(:each) do
    sign_in(user)
    task.project.members << user
  end

  describe "GET index" do
    it "sends tasks for the current user" do
      other_task = FactoryGirl.create(:task)
      other_task.project.members << FactoryGirl.create(:user)

      xhr :get, :index
      result = JSON.parse(response.body)
      result[0]['name'].should == task.name
      result.length.should == 1
    end
  end

  describe "GET show" do
    it "gets the task by id" do
      xhr :get, :show, {:id => task.id}
      response.should be_successful
      result = JSON.parse(response.body)
      result['name'].should == task.name
    end

    it "gets the task by slug" do
      xhr :get, :show, {:id => task.slug}
      response.should be_successful
      result = JSON.parse(response.body)
      result['name'].should == task.name
    end

    it "returns not found if the user isn't a member" do
      other_task = FactoryGirl.create(:task)  #creates a project that user isn't in
      xhr :get, :show, {:id => other_task.id}
      response.status.should == 404
    end

    it "returns not found if the task doesn't exist" do
      xhr :get, :show, {:id => "some crap that does not exist"}
      response.status.should == 404
    end
  end

  describe "POST new" do
    it "saves a new task for the current user" do
      project = task.project
      new_task = FactoryGirl.build(:task, project_id: project.id)
      xhr :post, :create, task: new_task.attributes.slice('name', 'description', 'project_id')
      response.should be_success
      Task.last.name.should eq(new_task.name)
    end

    it "returns not found when not a member of the task's project" do
      project = FactoryGirl.create(:project)
      new_task = FactoryGirl.build(:task, project_id: project.id)
      xhr :post, :create, task: new_task.attributes.slice('name', 'description', 'project_id')
      response.status.should == 404
    end
  end

  describe "PUT edit" do
    it "saves changes to an existing task" do
      xhr :put, :update, id: task.id, task: {name: "shiny new name"}
      response.should be_success
      Task.find(task.id)['name'].should == "shiny new name"
    end

    it "returns not found if attempting to edit when not a member of the task's project" do
      other_task = FactoryGirl.create(:task)
      xhr :put, :update, id: other_task.id, task: {name: "shiny new name"}
      response.status.should == 404
    end

    it "returns not found when attempting to move a task into a project when not a member" do
      project = FactoryGirl.create(:project)
      xhr :put, :update, id: task.id, task: {project_id: project.id}
      response.status.should == 404
    end
  end

  describe "DELETE destroy" do
    it "returns not found if not a member of the task's project" do
      other_task = FactoryGirl.create(:task)
      xhr :delete, :destroy, id: other_task.id
      response.status.should == 404
    end

    it "destroys the requested task" do
      xhr :delete, :destroy, id: task.id
      response.should be_success
      expect { Task.find(task.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
