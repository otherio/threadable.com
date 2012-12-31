class TasksController < ApplicationController

  before_filter :find, :only => [:show, :update, :destroy]

  # GET /tasks
  # GET /tasks.json
  def index
    # this doesn't scale.  we might not even need it.
    @tasks = current_user.projects.includes(:tasks).map(&:tasks).flatten

    @tasks = @tasks.where(slug: params[:slug]) if params[:slug]

    respond_to do |format|
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    respond_to do |format|
      format.json { render json: @task }
    end
  end

  # POST /tasks
  # POST /tasks.json
  def create
    if params[:task][:project_id] && ! Project.find(params[:task][:project_id]).project_memberships.where(:user_id => current_user.id).first
      return respond_to do |format|
        format.json { render nothing: true, status: :not_found }
      end
    end

    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        format.json { render json: @task, status: :created, location: @task }
      else
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    if params[:task][:project_id] && ! Project.find(params[:task][:project_id]).project_memberships.where(:user_id => current_user.id).first
      return respond_to do |format|
        format.json { render nothing: true, status: :not_found }
      end
    end

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.json { render json: @task, status: :ok, location: @task }
      else
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def find
    @task = Task.where('tasks.id = ? or tasks.slug = ?', params[:id], params[:id]).first

    if ! @task.present?
      return respond_to do |format|
        format.json { render nothing: true, status: :not_found }
      end
    end

    if ! @task.project.project_memberships.where(:user_id => current_user.id).first
      return respond_to do |format|
        format.json { render nothing: true, status: :not_found }
      end
    end

  end

end
