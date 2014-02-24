require 'spec_helper'

describe OrganizationsController do

  let(:creator){ double(:creator) }
  let(:new_organization){ double(:new_organization, creator: creator) }

  when_not_signed_in do
    describe "GET new" do
      it "redirects to the sign in page" do
        get :new, {}
        expect(response).to redirect_to sign_in_path(r: new_organization_path)
      end

      context 'when part of the sign up flow' do
        let(:organization_name){ 'my new org' }
        let(:email_address){ 'michael.faraday@gmail.com' }
        let(:token){ SignUpConfirmationToken.encrypt(organization_name, email_address) }

        it "renders the new organization form" do
          expect(NewOrganization).to receive(:new).with(threadable).and_return(new_organization)

          expect(new_organization).to receive(:organization_name=).with(nil)
          expect(new_organization).to receive(:organization_name=).with('my new org')
          expect(new_organization).to receive(:your_email_address=).with('michael.faraday@gmail.com')

          get :new, {token: token}
          expect(response).to render_template :new
        end
      end
    end

    describe "POST create" do
      it "redirects to the sign in page" do
        get :new, {}
        expect(response).to redirect_to sign_in_path(r: new_organization_path)
      end

      context 'when part of the sign up flow' do
        let(:organization_name){ 'my new org' }
        let(:email_address){ 'michael.faraday@gmail.com' }
        let(:token){ SignUpConfirmationToken.encrypt(organization_name, email_address) }

        context 'when the new organization is not valid' do
          before{ expect(new_organization).to receive(:create).and_return(false) }
          it "assigns a NewOrganization instance to @new_organization and renders new" do
            expect(NewOrganization).to receive(:new).with(threadable, {'organization_name' => 'my new org'}).and_return(new_organization)
            expect(new_organization).to receive(:your_email_address=).with(email_address)
            expect(controller).to_not receive(:sign_in!)
            expect(controller).to_not receive(:redirect_to)
            post :create, {
              token: token,
              new_organization: {organization_name: 'my new org'}
            }
            expect(response).to be_success
            expect(assigns(:new_organization)).to be new_organization
            expect(response).to render_template :new
          end
        end
        context 'when the new organization is valid' do
          before{ expect(new_organization).to receive(:create).and_return(true) }
          it "assigns a NewOrganization instance to @new_organization, creates the organization and signs in as the creator" do
            expect(NewOrganization).to receive(:new).with(threadable, {'organization_name' => 'my new org'}).and_return(new_organization)
            expect(new_organization).to receive(:your_email_address=).with(email_address)
            organization = double(:organization, to_param: 'my-new-org')
            expect(new_organization).to receive(:organization).and_return(organization)
            expect(controller).to receive(:sign_in!).with(creator)
            post :create, {
              token: token,
              new_organization: {organization_name: 'my new org'}
            }
            expect(assigns(:new_organization)).to be new_organization
            expect(response).to redirect_to controller.conversations_url('my-new-org', 'my')
          end
        end
      end

    end
  end

  when_signed_in_as 'bethany@ucsd.example.com' do
    describe "GET new" do
      it "assigns a NewOrganization instance to @new_organization" do
        get :new, {}
        expect(assigns(:new_organization)).to be_a(NewOrganization)
        expect(response).to render_template :new
      end
    end

    describe "POST create" do
      context 'when the new organization is not valid' do
        before{ expect(new_organization).to receive(:create).and_return(false) }
        it "assigns a NewOrganization instance to @new_organization and renders new" do
          expect(NewOrganization).to receive(:new).with(threadable, {'organization_name' => 'my new org'}).and_return(new_organization)
          expect(new_organization).to_not receive(:your_email_address=)
          expect(controller).to_not receive(:sign_in!)
          expect(controller).to_not receive(:redirect_to)
          post :create, {
            new_organization: {organization_name: 'my new org'}
          }
          expect(response).to be_success
          expect(assigns(:new_organization)).to be new_organization
          expect(response).to render_template :new
        end
      end
      context 'when the new organization is valid' do
        before{ expect(new_organization).to receive(:create).and_return(true) }
        it "assigns a NewOrganization instance to @new_organization and creates the organization" do
          expect(NewOrganization).to receive(:new).with(threadable, {'organization_name' => 'my new org'}).and_return(new_organization)
          organization = double(:organization, to_param: 'my-new-org')
          expect(new_organization).to receive(:organization).and_return(organization)
          expect(controller).to_not receive(:sign_in!)
          post :create, {
            new_organization: {organization_name: 'my new org'}
          }
          expect(assigns(:new_organization)).to be new_organization
          expect(response).to redirect_to controller.conversations_url('my-new-org', 'my')
        end
      end
    end
  end

  # before{ sign_in! find_user_by_email_address('bob@ucsd.example.com') }

  # let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }

  # def valid_attributes
  #   {
  #     "name" => "make robot cats",
  #   }
  # end


  # def valid_params
  #   {
  #     "organization" => {
  #       "name"        => valid_attributes["name"],
  #       "short_name"  => "robo cats",
  #       "description" => "make some roboty kitties",
  #     }
  #   }
  # end

  # def invalid_params
  #   {
  #     "organization" => {
  #       "name"        => "",
  #       "short_name"  => "",
  #       "subject_tag" => "",
  #       "description" => "",
  #     }
  #   }
  # end

  # describe "GET new" do
  #   it "assigns a new organization as @organization" do
  #     get :new, {}
  #     expect(assigns(:organization)).to be_a(Threadable::Organization)
  #     expect(assigns(:organization)).to_not be_persisted
  #   end
  # end

  # describe "GET edit" do
  #   before{ organization }
  #   it "assigns the requested organization as @organization" do
  #     get :edit, {:id => organization.to_param}
  #     assigns(:organization).should eq(organization)
  #   end
  # end

  # describe "POST create" do
  #   describe "with valid params" do
  #     it "creates a new Organization" do
  #       expect {
  #         post :create, valid_params
  #       }.to change(Organization, :count).by(1)
  #     end

  #     it "assigns a newly created organization as @organization" do
  #       post :create, valid_params
  #       expect(assigns(:organization)).to be_a(Threadable::Organization)
  #       expect(assigns(:organization)).to be_persisted
  #       expect(assigns(:organization).name       ).to eq valid_params["organization"]["name"]
  #       expect(assigns(:organization).short_name ).to eq valid_params["organization"]["short_name"]
  #       expect(assigns(:organization).description).to eq valid_params["organization"]["description"]
  #     end

  #     it "redirects to the created organization" do
  #       post :create, valid_params
  #       response.should redirect_to organization_url(Organization.last)
  #     end
  #   end

  #   describe "with invalid params" do
  #     it "assigns a newly created but unsaved organization as @organization" do
  #       post :create, invalid_params
  #       expect(assigns(:organization)).to be_a(Threadable::Organization)
  #       expect(assigns(:organization)).to_not be_persisted
  #     end

  #     it "re-renders the 'new' template" do
  #       post :create, invalid_params
  #       response.should render_template("new")
  #     end
  #   end
  # end

  # describe "PUT update" do

  #   before{ organization }

  #   def valid_params
  #     params = super.merge("id" => organization.to_param)
  #     params["organization"]["name"] = "make amazing robot cats"
  #     params
  #   end

  #   def invalid_params
  #     super.merge("id" => organization.to_param)
  #   end

  #   describe "with valid params" do
  #     it "updates the requested organization, assigns the requested organization as @organization, and redirects to the organization" do
  #       Organization.any_instance.should_receive(:update_attributes).with(valid_params["organization"]).and_return(true)
  #       put :update, valid_params
  #       assigns(:organization).should eq(organization)
  #       response.should redirect_to(root_path)
  #     end
  #   end

  #   describe "with invalid params" do
  #     it "assigns the organization as @organization" do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Organization.any_instance.stub(:update_attributes).and_return(false)
  #       put :update, invalid_params
  #       assigns(:organization).should eq(organization)
  #     end

  #     it "re-renders the 'edit' template" do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Organization.any_instance.stub(:update_attributes).and_return(false)
  #       put :update, invalid_params
  #       response.should render_template("edit")
  #     end
  #   end
  # end

  # # describe "DELETE destroy" do
  # #   before{ organization }

  # #   it "destroys the requested organization" do
  # #     expect {
  # #       delete :destroy, {:id => organization.to_param}
  # #     }.to change(Organization, :count).by(-1)
  # #   end

  # #   it "redirects to the organizations list" do
  # #     delete :destroy, {:id => organization.to_param}
  # #     response.should redirect_to(organizations_url)
  # #   end
  # # end

end
