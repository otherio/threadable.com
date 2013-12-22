require 'spec_helper'

describe OrganizationsController do

  before{ sign_in! find_user_by_email_address('bob@ucsd.covered.io') }

  let(:project){ current_user.projects.find_by_slug! 'raceteam' }

  def valid_attributes
    {
      "name" => "make robot cats",
    }
  end


  def valid_params
    {
      "project" => {
        "name"        => valid_attributes["name"],
        "short_name"  => "robo cats",
        "description" => "make some roboty kitties",
      }
    }
  end

  def invalid_params
    {
      "project" => {
        "name"        => "",
        "short_name"  => "",
        "subject_tag" => "",
        "description" => "",
      }
    }
  end

  describe "GET show" do
    before{ project }
    it "assigns the requested project as @project" do
      get :show, {:id => project.to_param}
      assigns(:project).should eq(project)
      response.should redirect_to project_conversations_url(project)
    end
  end

  describe "GET new" do
    it "assigns a new project as @project" do
      get :new, {}
      expect(assigns(:project)).to be_a(Covered::Organization)
      expect(assigns(:project)).to_not be_persisted
    end
  end

  describe "GET edit" do
    before{ project }
    it "assigns the requested project as @project" do
      get :edit, {:id => project.to_param}
      assigns(:project).should eq(project)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Organization" do
        expect {
          post :create, valid_params
        }.to change(Organization, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        post :create, valid_params
        expect(assigns(:project)).to be_a(Covered::Organization)
        expect(assigns(:project)).to be_persisted
        expect(assigns(:project).name       ).to eq valid_params["project"]["name"]
        expect(assigns(:project).short_name ).to eq valid_params["project"]["short_name"]
        expect(assigns(:project).description).to eq valid_params["project"]["description"]
      end

      it "redirects to the created project" do
        post :create, valid_params
        response.should redirect_to project_url(Organization.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        post :create, invalid_params
        expect(assigns(:project)).to be_a(Covered::Organization)
        expect(assigns(:project)).to_not be_persisted
      end

      it "re-renders the 'new' template" do
        post :create, invalid_params
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do

    before{ project }

    def valid_params
      params = super.merge("id" => project.to_param)
      params["project"]["name"] = "make amazing robot cats"
      params
    end

    def invalid_params
      super.merge("id" => project.to_param)
    end

    describe "with valid params" do
      it "updates the requested project, assigns the requested project as @project, and redirects to the project" do
        Organization.any_instance.should_receive(:update_attributes).with(valid_params["project"]).and_return(true)
        put :update, valid_params
        assigns(:project).should eq(project)
        response.should redirect_to(root_path)
      end
    end

    describe "with invalid params" do
      it "assigns the project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        Organization.any_instance.stub(:update_attributes).and_return(false)
        put :update, invalid_params
        assigns(:project).should eq(project)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Organization.any_instance.stub(:update_attributes).and_return(false)
        put :update, invalid_params
        response.should render_template("edit")
      end
    end
  end

  # describe "DELETE destroy" do
  #   before{ project }

  #   it "destroys the requested project" do
  #     expect {
  #       delete :destroy, {:id => project.to_param}
  #     }.to change(Organization, :count).by(-1)
  #   end

  #   it "redirects to the projects list" do
  #     delete :destroy, {:id => project.to_param}
  #     response.should redirect_to(projects_url)
  #   end
  # end

end
