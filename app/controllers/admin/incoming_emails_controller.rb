class Admin::IncomingEmailsController < ApplicationController

  before_filter :require_user_be_admin!

  PAGE_SIZE = 10

  # GET /admin/projects
  def index
    @page = (params[:page] || 0).to_i
    @filter = params[:filter]
    conditions = case @filter
    when 'all';                {}
    when 'not-processed';      {processed: false}
    when 'processed';          {processed: true}
    end
    @incoming_emails = covered.incoming_emails.page(@page, conditions)
  end

  # GET /admin/projects/:id
  def show
    @incoming_email = covered.incoming_emails.find_by_id!(params[:id])
  end

end
