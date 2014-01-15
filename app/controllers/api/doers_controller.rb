class Api::DoersController < ApiController

  # get /api/tasks
  def index
    task = organization.tasks.find_by_slug!(params[:task_id])
    render json: serialize(:doers, task.doers.all)
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id]) if params.key?(:organization_id)
  end
end
