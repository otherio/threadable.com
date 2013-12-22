require 'spec_helper'

describe OrganizationsController do

  before{ sign_in! find_user_by_email_address('bob@ucsd.covered.io') }

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }

  def valid_attributes
    {
      "name" => "make robot cats",
    }
  end


  def valid_params
    {
      "organization" => {
        "name"        => valid_attributes["name"],
        "short_name"  => "robo cats",
        "description" => "make some roboty kitties",
      }
    }
  end

  def invalid_params
    {
      "organization" => {
        "name"        => "",
        "short_name"  => "",
        "subject_tag" => "",
        "description" => "",
      }
    }
  end

  describe "GET show" do
    before{ organization }
    it "assigns the requested organization as @organization" do
      get :show, {:id => organization.to_param}
      assigns(:organization).should eq(organization)
      response.should redirect_to organization_conversations_url(organization)
    end
  end

  describe "GET new" do
    it "assigns a new organization as @organization" do
      get :new, {}
      expect(assigns(:organization)).to be_a(Covered::Organization)
      expect(assigns(:organization)).to_not be_persisted
    end
  end

  describe "GET edit" do
    before{ organization }
    it "assigns the requested organization as @organization" do
      get :edit, {:id => organization.to_param}
      assigns(:organization).should eq(organization)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Organization" do
        expect {
          post :create, valid_params
        }.to change(Organization, :count).by(1)
      end

      it "assigns a newly created organization as @organization" do
        post :create, valid_params
        expect(assigns(:organization)).to be_a(Covered::Organization)
        expect(assigns(:organization)).to be_persisted
        expect(assigns(:organization).name       ).to eq valid_params["organization"]["name"]
        expect(assigns(:organization).short_name ).to eq valid_params["organization"]["short_name"]
        expect(assigns(:organization).description).to eq valid_params["organization"]["description"]
      end

      it "redirects to the created organization" do
        post :create, valid_params
        response.should redirect_to organization_url(Organization.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved organization as @organization" do
        post :create, invalid_params
        expect(assigns(:organization)).to be_a(Covered::Organization)
        expect(assigns(:organization)).to_not be_persisted
      end

      it "re-renders the 'new' template" do
        post :create, invalid_params
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do

    before{ organization }

    def valid_params
      params = super.merge("id" => organization.to_param)
      params["organization"]["name"] = "make amazing robot cats"
      params
    end

    def invalid_params
      super.merge("id" => organization.to_param)
    end

    describe "with valid params" do
      it "updates the requested organization, assigns the requested organization as @organization, and redirects to the organization" do
        Organization.any_instance.should_receive(:update_attributes).with(valid_params["organization"]).and_return(true)
        put :update, valid_params
        assigns(:organization).should eq(organization)
        response.should redirect_to(root_path)
      end
    end

    describe "with invalid params" do
      it "assigns the organization as @organization" do
        # Trigger the behavior that occurs when invalid params are submitted
        Organization.any_instance.stub(:update_attributes).and_return(false)
        put :update, invalid_params
        assigns(:organization).should eq(organization)
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
  #   before{ organization }

  #   it "destroys the requested organization" do
  #     expect {
  #       delete :destroy, {:id => organization.to_param}
  #     }.to change(Organization, :count).by(-1)
  #   end

  #   it "redirects to the organizations list" do
  #     delete :destroy, {:id => organization.to_param}
  #     response.should redirect_to(organizations_url)
  #   end
  # end

end
