class Task::DoersController < ApplicationController

  before_filter :require_user_be_signed_in!

  # POST /conversations/1/add_doer
  # POST /conversations/1/add_doer.json
  def create
    member = project.members.find_by_user_id!(params[:doer_id])
    task.doers.add(member)

    respond_to do |format|
      format.html { redirect_to project_conversation_url(project, task), notice: "Added #{member.name} to this task."}
      format.json { render json: member, status: :created }
    end
  end

  def destroy
    member = project.members.find_by_user_id!(params[:id])
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

end
