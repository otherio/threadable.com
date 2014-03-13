class IntegrationHooksController < ApplicationController

  skip_before_action :require_user_be_signed_in!

  after_filter :trim_headers, only: :show

  def show
    provider = params.require(:provider)

    if provider == 'trello'
      begin
        organization
      rescue Threadable::RecordNotFound
        return head :gone
      end
      head :ok
    else
      head :bad_request
    end
  end

  def create
    provider = params.require(:provider)

    if provider == 'trello'
      begin
        process_params = params.
          except(:provider, :group_id, :organization_id, :controller, :action).
          merge({group: group, organization: organization, request: request}).
          symbolize_keys
      rescue Threadable::RecordNotFound
        return render nothing: true, status: :gone
      end

      Threadable::Integrations::TrelloProcessor.call(process_params)
      render nothing: true, status: :ok
    else
      render nothing: true, status: :bad_request
    end
  end

  def organization
    return @organization if @organization.present?
    @organization_id = params.require(:organization_id)
    @organization = threadable.organizations.find_by_slug!(@organization_id)
  end

  def group
    return @group if @group.present?
    @group_id = params.require(:group_id)
    @group = organization.groups.find_by_slug!(@group_id)
  end

  def trim_headers
    keep_headers = ['Content-length', 'Content-Type', 'Date', 'Server', 'Connection']
    response.headers.delete_if{|key| !keep_headers.include?(key)}
    response.headers['Content-length'] = '3'
  end
end
