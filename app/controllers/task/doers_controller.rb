class Task::DoersController < ApplicationController

  before_filter :require_user_be_signed_in!

  # POST /conversations/1/add_doer
  # POST /conversations/1/add_doer.json
  def create
    @task = project.tasks.where(slug: params[:task_id]).first!
    @doer = project.members.where(id: params[:doer_id]).first!
    @task.add_doers(current_user, @doer)

    respond_to do |format|
      format.html { redirect_to project_conversation_url(project, @task), notice: "Added #{@doer.name} to this task."}
      format.json { render json: {}, status: :created }
    end
  end

  def destroy
    @task = project.tasks.where(slug: params[:task_id]).first!
    @doer = @task.doers.where(id: params[:id]).first!
    @task.remove_doers(current_user, @doer)

    respond_to do |format|
      format.html { redirect_to project_conversation_url(project, @task), notice: "Removed #{@doer.name} from this task."}
      format.json { render json: {}, status: :no_content }
    end
  end

  private

  def project
    @project ||= current_user.projects.where(slug: params[:project_id]).first!
  end
end
