class Task::DoersController < ApplicationController

  before_filter :authenticate_user!

  before_filter do
    # raise "fuuuck"
  end

  # POST /conversations/1/add_doer
  # POST /conversations/1/add_doer.json
  def create
    @task = project.tasks.find_by_slug!(params[:task_id])
    @doer = project.members.where(id: params[:doer_id]).first!
    @task.doers << @doer
    Task::AddedDoerEvent.create!(
      task: @task,
      project: project,
      user: current_user,
      content: {doer_id: @doer.id}
    )

    respond_to do |format|
      format.html { redirect_to project_conversation_url(project, @task), notice: "Added #{@doer.name} to this task."}
      format.json { render json: {}, status: :created }
    end
  end

  def destroy
    @task = project.tasks.find_by_slug!(params[:task_id])
    @doer = @task.doers.where(id: params[:id]).first!
    @task.doers.delete(@doer)
    Task::RemovedDoerEvent.create!(
      task: @task,
      project: project,
      user: current_user,
      content: {doer_id: @doer.id}
    )

    respond_to do |format|
      format.html { redirect_to project_conversation_url(project, @task), notice: "Removed #{@doer.name} from this task."}
      format.json { render json: {}, status: :no_content }
    end
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end
end
