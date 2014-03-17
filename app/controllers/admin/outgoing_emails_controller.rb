class Admin::OutgoingEmailsController < ApplicationController

  layout 'old'

  before_action :require_user_be_admin!

  def edit
    @email_params = {}
  end

  def retry
    email = params.require(:email)
    message_id_header = email[:message_id]
    message_id_header = "<#{message_id_header}>" unless message_id_header =~ /<.+>/
    message = threadable.messages.find_by_message_id_header message_id_header

    unless message.present?
      flash[:error] = "Unable to find message with id #{message_id_header}"
      return redirect_to admin_outgoing_emails_path
    end

    user = message.organization.members.find_by_user_id(email[:user_id])

    unless user.present?
      flash[:error] = "Unable to find user with id #{email[:user_id]} in organization #{message.organization.name}"
      return redirect_to admin_outgoing_emails_path
    end

    message.not_sent_to!(user)
    message.send_email_for!(user)

    flash[:notice] = "Re-sent #{message.subject} to #{user.formatted_email_address}"

    redirect_to admin_outgoing_emails_path
  end

end
