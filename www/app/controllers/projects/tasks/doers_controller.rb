class Projects::Tasks::DoersController < ApplicationController

  before_filter :find_project
  before_filter :find_task

  # GET /project/task/doers
  # GET /project/task/doers.json
  def index
    @doers = @task.doers.all

    respond_to do |format|
      format.json { render json: @doers }
    end
  end

  # POST /project/task/doers
  # POST /project/task/doers.json
  def create
    @doer = @task.doers.new(params[:doer])

    respond_to do |format|
      if @doer.save
        format.json { render json: @doer, status: :created, location: @doer }
      else
        format.json { render json: @doer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /project/task/doers/1
  # DELETE /project/task/doers/1.json
  def destroy
    @doer = @task.doer.find(params[:id])
    @doer.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def find_project
    @project = current_user.projects.find(slug: params[:project_id]).first
    @project.present? or raise 'project not found'
  end

  def find_task
    @task = @project.tasks.find(slug: params[:task_id]).first
    @task.present? or raise 'task not found'
  end

end
