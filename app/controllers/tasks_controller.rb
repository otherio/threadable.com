class TasksController < ApplicationController

  before_filter :find, :only => [:show, :update, :destroy]

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.scoped

    @tasks = Project.find(params[:project_id]).tasks if params[:project_id]

    @tasks = @tasks.where(slug: params[:slug]) if params[:slug]

    respond_to do |format|
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.json { render json: @task }
    end
  end

  # POST /tasks
  # POST /tasks.json
  def create
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
    @task = Task.find(params[:id])
  end

end
