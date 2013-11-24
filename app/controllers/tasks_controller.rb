class TasksController < ApplicationController

  layout false

  before_filter :require_user_be_signed_in!

  respond_to :html, :json

  # POST /index
  # POST /index.json
  def index
    if request.xhr?
      render_tasks_sidebar
    else
      render nothing: true, status: :not_found
    end
  end

  # POST /tasks
  # POST /tasks.json
  def create
    subject = params.require(:task).require(:subject)
    @task = project.tasks.create(subject: subject)

    respond_to do |format|
      if @task.persisted?
        format.html {
          request.xhr? ? render_tasks_sidebar : redirect_to_show
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

  # PUT /:project_id/tasks/:id
  # PUT /:project_id/tasks/:id.json
  def update
    task
    task_params = params.require(:task).permit(:subject, :done, :done_at)

    if task_params && done = task_params.delete(:done)
      task_params[:done_at] = done == "true" ? Time.now : nil
    end

    respond_to do |format|
      if task.update(task_params)
        format.html { redirect_to_show notice: 'Task was successfully updated.' }
        format.json { render json: @task, status: :ok }
      else
        format.html { redirect_to_show error: 'We were unable to update your task. Please try again later.' }
        format.json { render json: @task, status: :unprocessable_entity }
      end
    end
  end

  include ForwardGetRequestsAsPostsConcern
  before_action :forward_get_requests_as_posts!, only: %w{
    ill_do_it
    remove_me
    mark_as_done
    mark_as_undone
  }

  def ill_do_it
    if task.doers.include? current_user
      redirect_to_show
    else
      task.doers.add current_user
      redirect_to_show notice: 'You have been added as a doer of this task.'
    end
  end

  def remove_me
    if task.doers.include? current_user
      task.doers.remove current_user
      redirect_to_show notice: 'You have been removed from the doers of this task.'
    else
      redirect_to_show
    end
  end

  def mark_as_done
    if task.done?
      redirect_to_show
    else
      task.done!
      redirect_to_show notice: 'Task marked as done.'
    end
  end

  def mark_as_undone
    if task.done?
      task.undone!
      redirect_to_show notice: 'Task marked as not done.'
    else
      redirect_to_show
    end
  end

  private

  def project_slug
    params[:project_id]
  end

  def task_slug
    params[:task_id] || params[:id]
  end

  def project
    @project ||= current_user.projects.find_by_slug! project_slug
  end

  def task
    @task ||= project.tasks.find_by_slug!(task_slug)
  end

  def tasks
    @tasks ||= project.tasks.all
  end

  def render_tasks_sidebar
    options = {}
    options[:with_title]    = true  if params[:with_title] == "true"
    options[:conversations] = false if params[:conversations] == "false"
    render text: render_widget(:tasks_sidebar, project, options)
  end

  def redirect_to_show options={}
    redirect_to project_conversation_url(project, @task), options
  end

end
