class TasksController < ApplicationController

  layout false

  before_filter :authenticate_user!

  respond_to :html, :json

  # POST /index
  # POST /index.json
  def index
    if request.xhr?
      render text: view_context.render_widget(:tasks_sidebar, project)
    else
      render nothing: true, status: :not_found
    end
  end

  # POST /tasks
  # POST /tasks.json
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
          render json: @task, status: :created, location: project_task_url(project, @task)
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

  # PUT /tasks
  # PUT /tasks.json
  def update
    @task = project.tasks.find_by_slug!(params[:id])
    @task.current_user = current_user

    if params[:task] && done = params[:task].delete(:done)
      params[:task][:done_at] = done == "true" ? Time.now : nil
    end

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to project_conversation_url(project, @task), notice: 'Task was successfully updated.' }
        format.json { render json: @task, status: :created, location: project_task_url(project, @task) }
      else
        format.html { redirect_to project_conversation_url(project, @task), error: 'We were unable to update your task. Please try again later.' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

end
