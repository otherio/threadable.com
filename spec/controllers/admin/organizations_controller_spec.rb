require 'spec_helper'

describe Admin::OrganizationsController do

  when_not_signed_in do

    describe 'GET :index' do
      it 'should render a 404' do
        get :index
        expect(response).to redirect_to sign_in_url(r: admin_organizations_url)
      end
    end

    describe 'GET :new' do
      it 'should render a 404' do
        get :new
        expect(response).to redirect_to sign_in_url(r: admin_new_organization_url)
      end
    end

    describe 'POST :create' do
      it 'should render a 404' do
        post :create
        expect(response).to redirect_to sign_in_url
      end
    end

    describe 'GET :edit' do
      it 'should render a 404' do
        get :edit, id: 'foo'
        expect(response).to redirect_to sign_in_url(r: admin_edit_organization_url)
      end
    end

    describe 'PUT :update' do
      it 'should render a 404' do
        put :update, id: 'foo'
        expect(response).to redirect_to sign_in_url
      end
    end

    describe 'DELETE :destroy' do
      it 'should render a 404' do
        delete :destroy, id: 'foo'
        expect(response).to redirect_to sign_in_url
      end
    end

  end

  when_signed_in_as 'ian@other.io' do

    describe 'GET :index' do
      it 'should render the index page' do
        organizations = double(:organizations)
        expect(threadable.organizations).to receive(:all).and_return(organizations)
        get :index
        expect(response).to render_template :index
        expect(assigns[:organizations]).to eq organizations
      end
    end

    describe 'GET :new' do
      it 'should render the new organization page' do
        new_organization = double(:new_organization)
        expect(threadable.organizations).to receive(:new).and_return(new_organization)
        get :new
        expect(response).to render_template :new
        expect(assigns[:organization]).to eq new_organization
      end
    end

    describe 'POST :create' do
      let(:organization_params){ { name: 'Robot Cow', add_current_user_as_a_member: "1", trusted: "1" } }
      let(:organization){ double(:organization, to_param: 'robot-cow', persisted?: persisted) }
      before do
        expect(threadable.organizations).to receive(:create).with(name: 'Robot Cow', add_current_user_as_a_member: true, trusted: true).and_return(organization)
        post :create, organization: organization_params
      end
      context 'when the organization is successfully created' do
        let(:persisted){ true }
        it 'should redirect to the organization edit page' do
          expect(response).to redirect_to admin_edit_organization_path('robot-cow')
          expect(flash[:notice]).to eq "Organization was successfully created."
        end
      end
      context 'when the organization is not successfully created' do
        let(:persisted){ false }
        it 'should render to the organization edit page' do
          expect(response).to render_template :new
          expect(assigns[:organization]).to eq organization
        end
      end
    end

    describe 'GET :edit' do
      let(:organization){ double :organization, members: double(:members) }
      let(:members){ double :members }
      before do
        expect(threadable.organizations).to receive(:find_by_slug!).with('low-rider').and_return(organization)
        expect(organization.members).to receive(:all).and_return(members)
      end
      it 'should render the organization edit page' do
        get :edit, id: 'low-rider'
        expect(response).to render_template :edit
        expect(assigns[:organization]).to eq organization
        expect(assigns[:members]).to eq members
      end
    end

    describe 'PUT :update' do
      let(:organization){ double :organization, members: double(:members), to_param: 'lowrider' }
      let(:organization_params){ {slug: 'lowrider'} }
      before do
        expect(threadable.organizations).to receive(:find_by_slug!).with('low-rider').and_return(organization)
        expect(organization).to receive(:update).with(organization_params).and_return(update_successful)
        put :update, id: 'low-rider', organization: organization_params
      end
      context 'when the organization is successfully updated' do
        let(:update_successful){ true }
        it 'should redirect to the organization edit page' do
          expect(response).to redirect_to admin_edit_organization_path('lowrider')
          expect(flash[:notice]).to eq "Organization was successfully updated."
        end
      end
      context 'when the organization is not successfully updated' do
        let(:update_successful){ false }
        it 'should render to the organization edit page' do
          expect(response).to render_template :edit
          expect(assigns[:organization]).to eq organization
        end
      end
    end

    describe 'DELETE :destroy' do
      let(:organization){ double :organization, members: double(:members), slug: 'lowrider' }
      before do
        expect(threadable.organizations).to receive(:find_by_slug!).with('low-rider').and_return(organization)
        expect(organization).to receive(:destroy!)
        delete :destroy, id: 'low-rider'
      end
      it 'should redirect to the admin organizations page' do
        expect(response).to redirect_to admin_organizations_url
        expect(flash[:notice]).to eq "Organization was successfully destroyed."
      end
    end

  end

end
