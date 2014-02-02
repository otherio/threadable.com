class Admin::IncomingEmailsController < ApplicationController

  layout 'old'

  before_action :require_user_be_admin!

  PAGE_SIZE = 10

  # GET /admin/organizations
  def index
    @page = (params[:page] || 0).to_i
    @filter = params[:filter]
    conditions = case @filter
    when 'all';                {}
    when 'not-processed';      {processed: false}
    when 'processed';          {processed: true}
    end
    @incoming_emails = threadable.incoming_emails.page(@page, conditions)
  end

  # GET /admin/organizations/:id
  def show
    @incoming_email = threadable.incoming_emails.find_by_id!(params[:id])
  end

end
