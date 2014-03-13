class Api::GroupsController < ApiController

  # get /api/groups
  def index
    render json: serialize(:groups, organization.groups.all)
  end

  # post /api/groups
  def create
    group_params = params.require(:group).permit(
      :color,
      :name,
      :subject_tag,
      :email_address_tag,
      :auto_join,
      :alias_email_address,
      :integration_type,
    )
    if params[:group][:integration_params].present?
      group_params[:integration_params] = params[:group][:integration_params].to_json
    end

    new_group = nil
    Threadable.transaction do
      new_group = organization.groups.create(group_params)
      new_group.setup_integration! if new_group.persisted? && new_group.has_integration?
    end

    if new_group.persisted?
      render json: serialize(:groups, new_group), status: 201
    else
      render json: {error: new_group.group_record.errors.full_messages.to_sentence}, status: 406
    end
  end

  # get /api/groups/:id
  def show
    render json: serialize(:groups, group)
  end

  # patch /api/groups/:id
  def update
    group = organization.groups.find_by_email_address_tag!(params[:id])
    group_params = params.require(:group).permit(
      :color,
      :subject_tag,
      :auto_join,
      :hold_messages,
      :alias_email_address,
      :webhook_url,
      :integration_type,
    )
    group_params[:webhook_url].try(&:strip)
    if params[:group][:integration_params].present?
      group_params[:integration_params] = params[:group][:integration_params].to_json
    end
    group.update(group_params)
    render json: serialize(:groups, group), status: 200
  end

  # post /api/groups/:id/join
  def join
    group.members.add(current_user) unless group.members.include? current_user
    render json: serialize(:groups, group)
  end

  # post /api/groups/:id/leave
  def leave
    group.members.remove(current_user) if group.members.include? current_user
    render json: serialize(:groups, group)
  end

  # delete /api/groups/:id
  def destroy
    group = organization.groups.find_by_email_address_tag!(params[:id])
    group.destroy
    render nothing: true, status: 204
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id]) if params.key?(:organization_id)
  end

  def group
    @group ||= organization.groups.find_by_slug!(params[:id] || params[:group_id])
  end

end
