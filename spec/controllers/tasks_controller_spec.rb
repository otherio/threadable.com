require 'spec_helper'

describe TasksController do

  let(:project){ Project.first }
  let(:current_user){ project.members.first }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

  def valid_attributes
    {
      "subject" => "Pickup a case of duct tape from Home Depot.",
    }
  end

  def valid_params
    {
      project_id: project.to_param
    }
  end

  describe "POST create" do

    def valid_params
      super.merge(task: valid_attributes)
    end

    describe "with valid params" do
      it "creates a new Task, assigns a newly created task as @task, and redirects to the created task" do
        expect { post :create, valid_params }.to change(Task, :count).by(1)
        assigns(:task).should be_a(Task)
        assigns(:task).should be_persisted
        response.should redirect_to project_conversation_url(project, assigns(:task))
      end
    end

    describe "with invalid params" do
      before do
        # Trigger the behavior that occurs when invalid params are submitted
        Task.any_instance.stub(:save).and_return(false)
      end
      it "assigns a newly created but unsaved task as @task, and re-renders the 'new' template" do
        post :create, valid_params
        assigns(:task).should be_a_new(Task)
        response.body.should be_blank
        response.should be_unprocessable
      end
    end

    context "when the format is json" do
      def valid_params
        super.merge(format: 'json')
      end
      describe "with valid params" do
        it "creates a new Task, assigns a newly created task as @task, and redirects to the created task" do
          expect { post :create, valid_params }.to change(Task, :count).by(1)
          assigns(:task).should be_a(Task)
          assigns(:task).should be_persisted
          response.body.should == assigns(:task).to_json
          response.should be_success
        end
      end

      describe "with invalid params" do
        before do
          # Trigger the behavior that occurs when invalid params are submitted
          Task.any_instance.stub(:save).and_return(false)
        end
        it "assigns a newly created but unsaved task as @task, and re-renders the 'new' template" do
          post :create, valid_params
          assigns(:task).should be_a_new(Task)
          response.should be_unprocessable
          response.body.should == assigns(:task).errors.to_json
        end
      end
    end

    context "when request is an xhr" do
      describe "with valid params" do
        it "creates a new Task, assigns a newly created task as @task, and redirects to the created task" do
          view_context = double(:view_context)
          controller.stub(:view_context).and_return(view_context)

          view_context.should_receive(:render_widget).
            with(:tasks_sidebar, project).
            and_return("FAKE TASKS SIDEBAR WIDGET")

          expect { xhr :post, :create, valid_params }.to change(Task, :count).by(1)
          assigns(:task).should be_a(Task)
          assigns(:task).should be_persisted
          response.should be_success
          response.body.should == "FAKE TASKS SIDEBAR WIDGET"
        end
      end

    end
  end


  describe "PUT update" do
    def valid_params
      super.merge(task: valid_attributes)
    end

    let!(:task){ Task.create!(valid_attributes.merge(project:project, creator: current_user)) }

    describe "with valid params" do
      it "updates the requested task" do
        now = Time.now
        Time.stub(:now).and_return(now)
        Task.any_instance.should_receive(:update_attributes).with({
          "subject" => "How aren't we going to build this thing?",
          "done_at" => Time.now,
        })
        put :update, valid_params.merge(:id => task.to_param, :task => {
          "subject" => "How aren't we going to build this thing?",
          "done" => "true",
        })
      end

      it "assigns the requested task as @task" do
        put :update, valid_params.merge(:id => task.to_param, :task => valid_attributes)
        assigns(:task).should eq(task)
      end

      it "redirects to the task" do
        put :update, valid_params.merge(:id => task.to_param, :task => valid_attributes)
        response.should redirect_to project_conversation_url(project, task)
      end
    end

    describe "with invalid params" do
      it "assigns the task as @task" do
        # Trigger the behavior that occurs when invalid params are submitted
        Task.any_instance.stub(:save).and_return(false)
        put :update, valid_params.update(:id => task.to_param, :task => {  })
        assigns(:task).should eq(task)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Task.any_instance.stub(:save).and_return(false)
        put :update, valid_params.update(:id => task.to_param, :task => {  })
        response.should redirect_to project_conversation_url(project, task)
      end
    end

  end

end
