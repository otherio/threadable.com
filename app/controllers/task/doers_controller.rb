class Task::DoersController < ApplicationController

  before_filter :authenticate_user!


  # POST /conversations/1/add_doer
  # POST /conversations/1/add_doer.json
  def create
    @task = project.tasks.find_by_slug!(params[:task_id])
    @doer = project.members.where(id: params[:doer_id]).first
    raise ActiveRecord::RecordNotFound unless @doer.present?

    respond_to do |format|
      @task.doers << @doer
      format.html { redirect_to project_conversation_url(project, @task), notice: "Added #{@doer.name} to this task."}
      format.json { head :created }
    end
  end

  def destroy
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end
end
