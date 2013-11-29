class Task::DoersController < ApplicationController

  before_filter :require_user_be_signed_in!

  # POST /:project_id/tasks/:task_id/doers
  def add
    task.doers.add(member)

    respond_to do |format|
      format.html { redirect_to project_conversation_url(project, task), notice: "Added #{member.name} to this task."}
      format.json { render json: member, status: :created }
    end
  end

  # DELETE /:project_id/tasks/:task_id/doers/:user_id
  def remove
    task.doers.remove(member)

    respond_to do |format|
      format.html { redirect_to project_conversation_url(project, task), notice: "Removed #{member.name} from this task."}
      format.json { render json: member, status: :ok }
    end
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

  def task
    @task ||= project.tasks.find_by_slug!(params[:task_id])
  end

  def member
    @member ||= project.members.find_by_user_id!(params.require(:user_id).to_i)
  end

end
