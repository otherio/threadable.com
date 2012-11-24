class TasksController < ApplicationController

  require_authentication!

  before_filter :find_project
  before_filter :find_task, :only => [:show, :edit, :update, :delete]

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = @project.tasks.find

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @task = @project.tasks.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = @project.tasks.new(params[:task])

    respond_to do |format|
      if @task.save
        format.html { redirect_to project_task_url(@task.project.slug, @task.slug), notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(params[:task]).save
        format.html { redirect_to project_task_url(@task.project.slug, @task.slug), notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to project_tasks_url(@task.project) }
      format.json { head :no_content }
    end
  end

  private

  def find_project
    @project = Multify::Project.find(slug: params[:project_id]).first
  end

  def find_task
    @task = @project.tasks.find(slug: params[:id]).first
    return true unless @task.nil?
    respond_to do |format|
      format.html { redirect_to project_tasks_url(@task.project) }
      format.json { render nothing: true, status: :not_found }
    end
  end

end
