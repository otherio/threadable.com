class TasksController < ApplicationController

  layout false

  before_filter :authenticate_user!
  before_action :find_task!, except: [:index,:create]

  respond_to :html, :json

  # POST /index
  # POST /index.json
  def index
    @project = current_user.projects.where(slug: params[:project_id]).includes(:tasks).first

    if request.xhr?
      render_widget
    else
      render nothing: true, status: :not_found
    end
  end

  # POST /tasks
  # POST /tasks.json
  def create
    task_params = params.require(:task).permit(:subject)
    @task = project.tasks.build(task_params.merge(creator: current_user))

    respond_to do |format|
      if @task.save
        format.html {
          request.xhr? ? render_widget : redirect_to_show
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
    task_params = params.require(:task).permit(:subject, :done, :done_at)

    if task_params && done = task_params.delete(:done)
      task_params[:done_at] = done == "true" ? Time.now : nil
    end

    respond_to do |format|
      if @task.update_attributes(task_params)
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
    @task.add_doers(current_user, current_user)
    redirect_to_show notice: 'You have been added as a doer of this task.'
  end

  def remove_me
    @task.remove_doers(current_user, current_user)
    redirect_to_show notice: 'You have been removed from the doers of this task.'
  end

  def mark_as_done
    @task.done!(current_user)
    redirect_to_show notice: 'Task marked as done.'
  end

  def mark_as_undone
    @task.undone!(current_user)
    redirect_to_show notice: 'Task marked as not done.'
  end

  private

  def project
    @project ||= current_user.projects.where(slug: params[:project_id]).first!
  end

  def render_widget
    options = {}
    options[:with_title]    = true  if params[:with_title] == "true"
    options[:conversations] = false if params[:conversations] == "false"
    render text: view_context.render_widget(:tasks_sidebar, project, options)
  end

  def find_task!
    slug = params[:task_id] || params[:id]
    @task = project.tasks.where(slug: slug).first!
    @task.current_user = current_user
  end

  def redirect_to_show options={}
    redirect_to project_conversation_url(project, @task), options
  end

end
