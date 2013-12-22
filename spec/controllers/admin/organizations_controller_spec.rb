require 'spec_helper'

describe Admin::OrganizationsController do

  when_not_signed_in do

    describe 'GET :index' do
      it 'should render a 404' do
        get :index
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'GET :new' do
      it 'should render a 404' do
        get :new
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'POST :create' do
      it 'should render a 404' do
        post :create
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'GET :edit' do
      it 'should render a 404' do
        get :edit, id: 'foo'
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'PUT :update' do
      it 'should render a 404' do
        put :update, id: 'foo'
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'DELETE :destroy' do
      it 'should render a 404' do
        delete :destroy, id: 'foo'
        expect(response).to render_template "errors/error_404"
      end
    end

  end

  when_signed_in_as 'ian@other.io' do

    describe 'GET :index' do
      it 'should render the index page' do
        projects = double(:projects)
        expect(covered.projects).to receive(:all).and_return(projects)
        get :index
        expect(response).to render_template :index
        expect(assigns[:projects]).to eq projects
      end
    end

    describe 'GET :new' do
      it 'should render the new project page' do
        new_project = double(:new_project)
        expect(covered.projects).to receive(:new).and_return(new_project)
        get :new
        expect(response).to render_template :new
        expect(assigns[:project]).to eq new_project
      end
    end

    describe 'POST :create' do
      let(:project_params){ { name: 'Robot Cow', add_current_user_as_a_member: "1" } }
      let(:project){ double(:project, to_param: 'robot-cow', persisted?: persisted) }
      before do
        expect(covered.projects).to receive(:create).with(name: 'Robot Cow', add_current_user_as_a_member: true).and_return(project)
        post :create, project: project_params
      end
      context 'when the project is successfully created' do
        let(:persisted){ true }
        it 'should redirect to the project edit page' do
          expect(response).to redirect_to admin_edit_project_path('robot-cow')
          expect(flash[:notice]).to eq "Organization was successfully created."
        end
      end
      context 'when the project is not successfully created' do
        let(:persisted){ false }
        it 'should render to the project edit page' do
          expect(response).to render_template :new
          expect(assigns[:project]).to eq project
        end
      end
    end

    describe 'GET :edit' do
      let(:project){ double :project, members: double(:members) }
      let(:members){ double :members }
      before do
        expect(covered.projects).to receive(:find_by_slug!).with('low-rider').and_return(project)
        expect(project.members).to receive(:all).and_return(members)
      end
      it 'should render the project edit page' do
        get :edit, id: 'low-rider'
        expect(response).to render_template :edit
        expect(assigns[:project]).to eq project
        expect(assigns[:members]).to eq members
      end
    end

    describe 'PUT :update' do
      let(:project){ double :project, members: double(:members), to_param: 'lowrider' }
      let(:project_params){ {slug: 'lowrider'} }
      before do
        expect(covered.projects).to receive(:find_by_slug!).with('low-rider').and_return(project)
        expect(project).to receive(:update).with(project_params).and_return(update_successful)
        put :update, id: 'low-rider', project: project_params
      end
      context 'when the project is successfully updated' do
        let(:update_successful){ true }
        it 'should redirect to the project edit page' do
          expect(response).to redirect_to admin_edit_project_path('lowrider')
          expect(flash[:notice]).to eq "Organization was successfully updated."
        end
      end
      context 'when the project is not successfully updated' do
        let(:update_successful){ false }
        it 'should render to the project edit page' do
          expect(response).to render_template :edit
          expect(assigns[:project]).to eq project
        end
      end
    end

    describe 'DELETE :destroy' do
      let(:project){ double :project, members: double(:members), slug: 'lowrider' }
      before do
        expect(covered.projects).to receive(:find_by_slug!).with('low-rider').and_return(project)
        expect(project).to receive(:destroy!)
        delete :destroy, id: 'low-rider'
      end
      it 'should redirect to the admin projects page' do
        expect(response).to redirect_to admin_projects_url
        expect(flash[:notice]).to eq "Organization was successfully destroyed."
      end
    end

  end

end
