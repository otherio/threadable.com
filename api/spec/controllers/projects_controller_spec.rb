require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe ProjectsController do

  # This should return the minimal set of attributes required to create a valid
  # Project. As you add validations to Project, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "name" => "A Project" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ProjectsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

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
      get :index, {}, valid_session
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
      other_project.members << FactoryGirl.create(:user)

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

  # describe "GET edit" do
  #   it "assigns the requested project as @project" do
  #     project = Project.create! valid_attributes
  #     get :edit, {:id => project.to_param}, valid_session
  #     assigns(:project).should eq(project)
  #   end
  # end

  # describe "POST create" do
  #   describe "with valid params" do
  #     it "creates a new Project" do
  #       expect {
  #         post :create, {:project => valid_attributes}, valid_session
  #       }.to change(Project, :count).by(1)
  #     end

  #     it "assigns a newly created project as @project" do
  #       post :create, {:project => valid_attributes}, valid_session
  #       assigns(:project).should be_a(Project)
  #       assigns(:project).should be_persisted
  #     end

  #     it "redirects to the created project" do
  #       post :create, {:project => valid_attributes}, valid_session
  #       response.should redirect_to(Project.last)
  #     end
  #   end

  #   describe "with invalid params" do
  #     it "assigns a newly created but unsaved project as @project" do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Project.any_instance.stub(:save).and_return(false)
  #       post :create, {:project => { "name" => "invalid value" }}, valid_session
  #       assigns(:project).should be_a_new(Project)
  #     end

  #     it "re-renders the 'new' template" do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Project.any_instance.stub(:save).and_return(false)
  #       post :create, {:project => { "name" => "invalid value" }}, valid_session
  #       response.should render_template("new")
  #     end
  #   end
  # end

  # describe "PUT update" do
  #   describe "with valid params" do
  #     it "updates the requested project" do
  #       project = Project.create! valid_attributes
  #       # Assuming there are no other projects in the database, this
  #       # specifies that the Project created on the previous line
  #       # receives the :update_attributes message with whatever params are
  #       # submitted in the request.
  #       Project.any_instance.should_receive(:update_attributes).with({ "name" => "MyString" })
  #       put :update, {:id => project.to_param, :project => { "name" => "MyString" }}, valid_session
  #     end

  #     it "assigns the requested project as @project" do
  #       project = Project.create! valid_attributes
  #       put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
  #       assigns(:project).should eq(project)
  #     end

  #     it "redirects to the project" do
  #       project = Project.create! valid_attributes
  #       put :update, {:id => project.to_param, :project => valid_attributes}, valid_session
  #       response.should redirect_to(project)
  #     end
  #   end

  #   describe "with invalid params" do
  #     it "assigns the project as @project" do
  #       project = Project.create! valid_attributes
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Project.any_instance.stub(:save).and_return(false)
  #       put :update, {:id => project.to_param, :project => { "name" => "invalid value" }}, valid_session
  #       assigns(:project).should eq(project)
  #     end

  #     it "re-renders the 'edit' template" do
  #       project = Project.create! valid_attributes
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Project.any_instance.stub(:save).and_return(false)
  #       put :update, {:id => project.to_param, :project => { "name" => "invalid value" }}, valid_session
  #       response.should render_template("edit")
  #     end
  #   end
  # end

  # describe "DELETE destroy" do
  #   it "destroys the requested project" do
  #     project = Project.create! valid_attributes
  #     expect {
  #       delete :destroy, {:id => project.to_param}, valid_session
  #     }.to change(Project, :count).by(-1)
  #   end

  #   it "redirects to the projects list" do
  #     project = Project.create! valid_attributes
  #     delete :destroy, {:id => project.to_param}, valid_session
  #     response.should redirect_to(projects_url)
  #   end
  # end

end
