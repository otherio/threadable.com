class TasksController < ApplicationController

  layout false

  before_filter :authenticate_user!

  respond_to :html, :json

  # POST /conversations
  # POST /conversations.json
  def create
    @task = project.tasks.build(params[:task].merge(creator: current_user))

    respond_to do |format|
      if @task.save
        format.html {
          if request.xhr?
            render text: view_context.render_widget(:tasks_sidebar, project)
          else
            redirect_to project_conversation_url(project, @task)
          end
        }
        format.json {
          render json: @task, status: :created, location: project_conversation_url(project, @task)
        }
      else
        format.html {
          render nothing: true, status: :unprocessable_entity
        }
        format.json {
          render json: @task.errors, status: :unprocessable_entity
        }
      end
    end
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

end
