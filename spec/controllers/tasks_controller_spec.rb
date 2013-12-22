require 'spec_helper'

describe TasksController do

  when_not_signed_in do

    describe "GET index" do
      it 'should redirect to a sign in page' do
        get :index, organization_id: 'raceteam'
        expect(response).to be_redirect
      end
    end

    describe "POST create" do
      it 'should redirect to a sign in page' do
        post :create, organization_id: 'raceteam'
        expect(response).to be_redirect
      end
    end

    describe "PATCH update" do
      it 'should redirect to a sign in page' do
        patch :update, organization_id: 'raceteam', id: 1
        expect(response).to be_redirect
      end
    end

    describe "PUT update" do
      it 'should redirect to a sign in page' do
        patch :update, organization_id: 'raceteam', id: 1
        expect(response).to be_redirect
      end
    end

    %w{ill_do_it remove_me mark_as_done mark_as_undone}.each do |action|
      describe "GET #{action}" do
        it 'should redirect to a sign in page' do
          get action, organization_id: 'raceteam', task_id: 1
          expect(response).to be_redirect
        end
      end

      describe "POST #{action}" do
        it 'should redirect to a sign in page' do
          post action, organization_id: 'raceteam', task_id: 1
          expect(response).to be_redirect
        end
      end
    end

  end

  when_signed_in_as 'alice@ucsd.covered.io' do

    describe "GET index" do
      it "should render a 404" do
        get :index, organization_id: 'raceteam'
        expect(response.status).to eq 404
      end
    end

    describe "XHR GET index" do
      it "should render the tasks_sidebar widget" do
        expect(controller).to receive(:render_widget) do |widget_name, organization, options|
          expect(widget_name).to eq :tasks_sidebar
          expect(organization.slug).to eq 'raceteam'
          expect(options).to eq({})
        end
        xhr :get, :index, organization_id: 'raceteam'
      end
    end

    describe 'create' do

      def xhr?
        false
      end

      def request! options={}
        options = {organization_id: 'raceteam'}.merge(options)
        if xhr?
          xhr :post, :create, options
        else
          post :create, options
        end
      end

      shared_context 'creating a task' do
        let(:organization_double){ double(:organization, to_param: 'raceteam') }
        let(:tasks_double)  { double(:tasks)   }
        let(:task_double)   { double(:task, persisted?: task_persisted, to_param: 'poop-on-a-cat') }

        before do
          expect(current_user.organizations).to receive(:find_by_slug!).with('raceteam').and_return(organization_double)
          expect(organization_double).to receive(:tasks).and_return(tasks_double)
          expect(tasks_double).to receive(:create).with(subject: "poop on a cat").and_return(task_double)
          #
        end
      end

      shared_context "when the task[subject] param is missing" do
        it "should raise a ActionController::ParameterMissing error" do
          expect{ request!               }.to raise_error ActionController::ParameterMissing, 'param not found: task'
          expect{ request! task: {foo:1} }.to raise_error ActionController::ParameterMissing, 'param not found: subject'
        end
      end

      shared_examples "when the task creation failes" do
        context "when the task creation failes" do
          include_context 'creating a task'
          let(:task_persisted){ false }
          it "should redering nothing 422 " do
            request! task: {subject: "poop on a cat"}
            expect(response.body).to be_blank
            expect(response.status).to eq 422
          end
        end
      end

      describe "POST" do
        include_context "when the task[subject] param is missing"
        it_behaves_like "when the task creation failes"
        context "when the task creation succeeds" do
          include_context 'creating a task'
          let(:task_persisted){ true }
          it "should redirect me to the show page" do
            request! task: {subject: "poop on a cat"}
            expect(response).to redirect_to organization_conversation_url('raceteam', 'poop-on-a-cat')
          end
        end
      end

      describe "XHR POST" do
        def xhr?
          true
        end
        include_context "when the task[subject] param is missing"
        it_behaves_like "when the task creation failes"
        context "when the task creation succeeds" do
          include_context 'creating a task'
          let(:task_persisted){ true }
          it "should render the tasks_sidebar widget" do
            expect(controller).to receive(:render_widget) do |widget_name, organization, options|
              expect(widget_name).to eq :tasks_sidebar
              expect(organization).to eq organization_double
              expect(options).to eq({})
            end
            request! task: {subject: "poop on a cat"}
          end
        end
      end

    end

    describe "PUT update" do
      let(:organization_slug) { 'yourmom' }
      let(:organization){ double(:organization) }
      let(:task_slug){ 'send-mom-a-chicken' }
      let(:tasks){ double(:tasks) }
      let(:task){ double(:task) }
      before do
        expect(current_user.organizations).to receive(:find_by_slug!).with(organization_slug).and_return(organization)
        expect(organization).to receive(:tasks).and_return(tasks)
        expect(tasks).to receive(:find_by_slug!).with(task_slug).and_return(task)
      end

      context "when the update is successful" do
        before do
          expect(task).to receive(:update).with("position" => 99).and_return(true)
        end
        it "updates the task's position" do
          patch :update, organization_id: 'yourmom', id: task_slug, task: {position: 99, something: 'else'}, format: :json
          expect(response).to be_successful
          expect(response.body).to eq task.to_json
        end
      end

      context "when the update is not successful" do
        before do
          expect(task).to receive(:update).with("position" => 99).and_return(false)
        end
        it "updates renders an error" do
          patch :update, organization_id: 'yourmom', id: task_slug, task: {position: 99, something: 'else'}, format: :json
          expect(response).to_not be_successful
          expect(response.body).to eq task.to_json
        end
      end


    end

  end

end
