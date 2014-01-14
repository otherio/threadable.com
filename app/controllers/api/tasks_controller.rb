class Api::TasksController < ApiController

  # get /api/tasks
  def index
    render json: serialize(:tasks, tasks.all)
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id])
  end

  def group?
    params.key?(:group_id)
  end

  def group
    @group ||= organization.groups.find_by_email_address_tag!(params[:group_id])
  end

  def tasks
    @tasks ||= group? ? group.tasks : organization.tasks
  end
end
