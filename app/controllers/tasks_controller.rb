class TasksController < ApplicationController

  layout false

  before_filter :authenticate_user!

  # POST /conversations
  # POST /conversations.json
  def create
    @task = project.tasks.create!(params[:task])

    respond_to do |format|
      if @task.save
        format.html {
          if request.xhr?
            render text: view_context.render_widget(:tasks_sidebar, project)
          end
        }
        format.json { render json: @task, status: :created, location: project_conversation_url(project, @task) }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

end
