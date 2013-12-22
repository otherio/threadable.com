require 'spec_helper'

describe Organization::HeldMessagesController do


  when_not_signed_in do
    describe 'GET /:project_id/held_messages' do
      it 'should redirect you to the sign in page' do
        get :index, project_id: 'raceteam'
        expect(response).to redirect_to sign_in_path(r: project_held_messages_url('raceteam'))
      end
    end
    describe 'POST /:project_id/held_messages/:id/accept' do
      it 'should redirect you to the sign in page' do
        post :accept, project_id: 'raceteam', id: 12
        expect(response).to redirect_to sign_in_path
      end
    end
    describe 'POST /:project_id/held_messages/:id/reject' do
      it 'should redirect you to the sign in page' do
        post :accept, project_id: 'raceteam', id: 12
        expect(response).to redirect_to sign_in_path
      end
    end
  end

  when_signed_in_as 'bob@ucsd.covered.io' do

    let(:project){ current_user.projects.find_by_slug! 'raceteam' }

    before do
      @incoming_email = project.incoming_emails.create!(create_incoming_email_params(
        from: 'Foo Bar <foo@bar.com>',
        envelope_from: '<foo@bar.com>',
      ))
      drain_background_jobs!
    end
    attr_reader :incoming_email

    describe 'GET /:project_id/held_messages' do
      it 'should get all the held incoming emails for the current project' do
        get :index, project_id: 'raceteam'
        expect(response).to be_success
        expect(assigns[:held_messages]).to eq project.held_messages.all
      end
    end

    describe 'POST /:project_id/held_messages/:id/accept' do
      it 'should accepts the given incoming email' do
        post :accept, project_id: 'raceteam', id: incoming_email.id
        expect(response).to redirect_to project_held_messages_path(project)
        drain_background_jobs!
        incoming_email.reload!
        expect(incoming_email).to_not be_held
        expect(incoming_email).to be_delivered
      end
    end

    describe 'POST /:project_id/held_messages/:id/reject' do
      it 'should rejects the given incoming email' do
        post :reject, project_id: 'raceteam', id: incoming_email.id
        expect(response).to redirect_to project_held_messages_path(project)
        drain_background_jobs!
        expect(covered.incoming_emails.find_by_id(incoming_email.id)).to be_nil
      end
    end

  end

end
