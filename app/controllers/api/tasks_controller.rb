class Api::TasksController < ApiController

  # get /api/tasks
  def index
    render json: serialize(tasks.all)
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id]) if params.key?(:organization_id)
  end

  def group
    @group ||= organization.groups.find_by_email_address_tag!(params[:group_id]) if params.key?(:group_id)
  end

  def tasks
    # this is here because it will one day return current_user.tasks when an organiztion_id is not given
    if group.present?
      @tasks ||= group.tasks
    else
      @tasks ||= organization.tasks
    end
  end
end
