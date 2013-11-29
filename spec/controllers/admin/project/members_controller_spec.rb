require 'spec_helper'

describe Admin::Project::MembersController do

  when_not_signed_in do

    describe 'POST :add' do
      it 'should render a 404' do
        post :add, project_id: 'fish-eating-contest'
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'PUT :update' do
      it 'should render a 404' do
        put :update, project_id: 'fish-eating-contest', user_id: 42
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'DELETE :remove' do
      it 'should render a 404' do
        delete :remove, project_id: 'fish-eating-contest', user_id: 42
        expect(response).to render_template "errors/error_404"
      end
    end

  end

  when_signed_in_as 'ian@other.io' do
    let(:project){ double :project, name: 'Fish Eating Contest', to_param: 'fish-eating-contest', members: double(:members) }
    let :member_params do
      {
        name:             'Mary Frank',
        email_address:    'mary@frank.ly',
        gets_email:       false,
        send_join_notice: false,
      }
    end
    let(:member){ double(:member, formatted_email_address: 'Mary Frank <mary@frank.ly>') }
    before do
      expect(covered.projects).to receive(:find_by_slug!).with('fish-eating-contest').and_return(project)
    end

    describe 'POST :add' do

      let(:user){ double(:user, formatted_email_address: 'Mary Frank <mary@frank.ly>') }

      context 'adding member via user_id' do
        let :member_params do
          {
            id:               898,
            gets_email:       false,
            send_join_notice: false,
          }
        end

        context 'when the user doesnt exist' do
          before{ expect(covered.users).to receive(:find_by_id!).with(898).and_raise(Covered::RecordNotFound) }
          it 'should alert that the user is not found' do
            post :add, project_id: 'fish-eating-contest', user: member_params
            expect(response).to redirect_to admin_edit_project_url(project)
            expect(flash[:alert]).to eq "unable to find user 898"
          end
        end

        context 'when the user already exists' do
          before{ expect(covered.users).to receive(:find_by_id!).with(898).and_return(user) }

          context 'and the user is already a member of the project' do
            before{ expect(project.members).to receive(:include?).with(user).and_return(true) }
            it 'redirect back to the admin project edit page with an alert' do
              post :add, project_id: 'fish-eating-contest', user: member_params
              expect(response).to redirect_to admin_edit_project_url(project)
              expect(flash[:alert]).to eq "Mary Frank <mary@frank.ly> is already a meber of Fish Eating Contest."
            end
          end
          context 'and the user is not a member of the project' do
            before{ expect(project.members).to receive(:include?).with(user).and_return(false) }
            it 'redirect back to the admin project edit page with an success notice' do
              expect(project.members).to receive(:add).with(user: user, gets_email: false, send_join_notice: false).and_return(member)
              post :add, project_id: 'fish-eating-contest', user: member_params
              expect(response).to redirect_to admin_edit_project_url(project)
              expect(flash[:notice]).to eq "Mary Frank <mary@frank.ly> was successfully added to Fish Eating Contest."
            end
          end
        end

      end

      context 'adding member email_address' do

        context 'when the user doesnt exist' do
          before do
            expect(covered.users).to receive(:find_by_email_address).with(member_params[:email_address]).and_return(nil)
            expect(covered.users).to receive(:create!).with(name: member_params[:name], email_address: member_params[:email_address]).and_return(user)
            expect(project.members).to receive(:include?).with(user).and_return(false)
            expect(project.members).to receive(:add).with(user: user, gets_email: false, send_join_notice: false).and_return(member)
          end

          it 'it should create a new user, add them to the project and redirect back to the admin project edit page' do
            post :add, project_id: 'fish-eating-contest', user: member_params
            expect(response).to redirect_to admin_edit_project_url(project)
            expect(flash[:notice]).to eq "Mary Frank <mary@frank.ly> was successfully added to Fish Eating Contest."
          end
        end

        context 'when the user already exists' do
          before do
            expect(covered.users).to receive(:find_by_email_address).with(member_params[:email_address]).and_return(user)
            expect(covered.users).to_not receive(:create!)
          end

          context 'and the user is already a member of the project' do
            before{ expect(project.members).to receive(:include?).with(user).and_return(true) }
            it 'redirect back to the admin project edit page with an alert' do
              post :add, project_id: 'fish-eating-contest', user: member_params
              expect(response).to redirect_to admin_edit_project_url(project)
              expect(flash[:alert]).to eq "Mary Frank <mary@frank.ly> is already a meber of Fish Eating Contest."
            end
          end
          context 'and the user is not a member of the project' do
            before{ expect(project.members).to receive(:include?).with(user).and_return(false) }
            it 'redirect back to the admin project edit page with an success notice' do
              expect(project.members).to receive(:add).with(user: user, gets_email: false, send_join_notice: false).and_return(member)
              post :add, project_id: 'fish-eating-contest', user: member_params
              expect(response).to redirect_to admin_edit_project_url(project)
              expect(flash[:notice]).to eq "Mary Frank <mary@frank.ly> was successfully added to Fish Eating Contest."
            end
          end
        end

      end
    end

    describe 'PUT :update' do
      before do
        expect(project.members).to receive(:find_by_user_id!).with("42").and_return(member)
        expect(member).to receive(:update).with(member_params).and_return(update_successful)
        put :update, project_id: 'fish-eating-contest', user_id: 42, user: member_params
        expect(response).to redirect_to admin_edit_project_url(project)
      end
      context 'when the update is successfull' do
        let(:update_successful){ true }
        it 'should redirect to the admin edit project page' do
          expect(flash[:notice]).to eq "update of Mary Frank <mary@frank.ly> membership to Fish Eating Contest was successful."
        end
      end
      context 'when the update is unsuccessfull' do
        let(:update_successful){ false }
        it 'should redirect to the admin edit project page' do
          expect(flash[:alert]).to eq "update of Mary Frank <mary@frank.ly> membership to Fish Eating Contest was unsuccessful."
        end
      end

    end

    describe 'DELETE :remove' do
      context 'when the user is a member of the project' do
        before{ expect(project.members).to receive(:find_by_user_id).with(42).and_return(member) }
        it 'should redirect to the admin projects page' do
          expect(project.members).to receive(:remove).with(user: member)
          delete :remove, project_id: 'fish-eating-contest', user_id: 42
          expect(response).to redirect_to admin_edit_project_path('fish-eating-contest')
          expect(flash[:notice]).to eq "Mary Frank <mary@frank.ly> was successfully removed from Fish Eating Contest."
        end
      end
      context 'when the user is not a member of the project' do
        before{ expect(project.members).to receive(:find_by_user_id).with(42).and_return(nil) }
        it 'should redirect to the admin projects page' do
          expect(project.members).to_not receive(:remove)
          delete :remove, project_id: 'fish-eating-contest', user_id: 42
          expect(response).to redirect_to admin_edit_project_path('fish-eating-contest')
          expect(flash[:alert]).to eq "user 42 is not a member of Fish Eating Contest."
        end
      end
    end

  end

end
