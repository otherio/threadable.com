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
    integration_params = params.except(:group_id, :organization_id, :controller, :action)

    begin
      threadable.incoming_integration_hooks.create!(organization, group, request, integration_params)
    rescue Threadable::RecordNotFound
      return render nothing: true, status: :gone
    end

    # enqueue the job.

    render nothing: true, status: :ok
  rescue Threadable::RecordInvalid => error
    threadable.report_exception!(error)
    render nothing: true, status: :bad_request
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
