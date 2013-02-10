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

  let(:user){ create(:user) }

  before do
    sign_in user
  end

  # This should return the minimal set of attributes required to create a valid
  # Project. As you add validations to Project, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "name" => "Make a flying horse" }
  end

  describe "GET index" do
    it "assigns all projects as @projects" do
      project = user.projects.create! valid_attributes
      get :index, {}
      response.should be_success
      assigns(:projects).should eq([project])
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      project = user.projects.create! valid_attributes
      get :show, {:project_id => project.to_param}
      assigns(:project).should eq(project)
    end
  end

  describe "GET new" do
    it "assigns a new project as @project" do
      get :new, {}
      assigns(:project).should be_a_new(Project)
    end
  end

  describe "GET edit" do
    it "assigns the requested project as @project" do
      project = user.projects.create! valid_attributes
      get :edit, {:project_id => project.to_param}
      assigns(:project).should eq(project)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Project" do
        expect {
          post :create, {:project => valid_attributes}
        }.to change(Project, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        post :create, {:project => valid_attributes}
        assigns(:project).should be_a(Project)
        assigns(:project).should be_persisted
      end

      it "redirects to the created project" do
        post :create, {:project => valid_attributes}
        response.should redirect_to(Project.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        post :create, {:project => { "name" => "invalid value" }}
        assigns(:project).should be_a_new(Project)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        post :create, {:project => { "name" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested project" do
        project = user.projects.create! valid_attributes
        # Assuming there are no other projects in the database, this
        # specifies that the Project created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Project.any_instance.should_receive(:update_attributes).with({ "name" => "MyString" })
        put :update, {:id => project.to_param, :project => { "name" => "MyString" }}
      end

      it "assigns the requested project as @project" do
        project = user.projects.create! valid_attributes
        put :update, {:id => project.to_param, :project => valid_attributes}
        assigns(:project).should eq(project)
      end

      it "redirects to the project" do
        project = user.projects.create! valid_attributes
        put :update, {:id => project.to_param, :project => valid_attributes}
        response.should redirect_to(project)
      end
    end

    describe "with invalid params" do
      it "assigns the project as @project" do
        project = user.projects.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        put :update, {:id => project.to_param, :project => { "name" => "invalid value" }}
        assigns(:project).should eq(project)
      end

      it "re-renders the 'edit' template" do
        project = user.projects.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        put :update, {:id => project.to_param, :project => { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested project" do
      project = user.projects.create! valid_attributes
      expect {
        delete :destroy, {:id => project.to_param}
      }.to change(Project, :count).by(-1)
    end

    it "redirects to the projects list" do
      project = user.projects.create! valid_attributes
      delete :destroy, {:id => project.to_param}
      response.should redirect_to(projects_url)
    end
  end

  describe "GET user_search" do
    let!(:project) {create(:project) }
    let!(:user_alice) { create(:user, name: 'Alice', email: 'alice@example.com') }
    let!(:user_bob) { create(:user, name: 'Bob', email: 'bob@example.com') }

    before do
      project.members << [user_alice, user_bob]
    end

    context "searching by email address" do
      subject { xhr :get, :user_search, {:project_id => project.to_param, :q => 'exampl'} }

      it "fetches users by email address" do
        subject
        response.should be_success
        result = response.body.JSON_decode
        result.length.should == 2
      end

      it "correctly formats its results" do
        subject
        result = response.body.JSON_decode
        result.should =~ [
          { 'name' => 'Alice', 'email' => 'alice@example.com', 'id' => alice_user.id },
          { 'name' => 'Bob', 'email' => 'bob@example.com', 'id' => bob_user.id },
        ]
      end
    end

    context "searching by name" do
      subject { xhr :get, :user_search, {:project_id => project.to_param, :q => 'ali'} }

      it "fetches users by name substring" do
        subject
        response.should be_success
        result = response.body.JSON_decode
        result.length.should == 1
      end
    end

    context "with many users" do
      before do
        (1..20).each do |seq|
          create(:user, email: "#{seq}@example.com")
        end
      end

      it "fetches a maximum of ten results" do
        xhr :get, :user_search, {:project_id => project.to_param, :q => 'example.com'}
        result = response.body.JSON_decode
        result.length.should == 10
      end
    end

    context "when the user doesn't have access to this project" do
      it "returns a 404 or something" do
        pending
      end
    end

    context "when fetching HTML instead of json" do
      it "returns not implemented, or something like that" do
      end
    end
  end
end
