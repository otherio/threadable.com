class EmailActionsController < ApplicationController

  include ForwardGetRequestsAsPostsConcern

  skip_before_action :require_user_be_signed_in!

  def show
    forward_get_requests_as_posts!
  end

  def take
    record_id, user_id, action = EmailActionToken.decrypt(params[:token])

    @email_action = EmailAction.new(threadable, action, user_id, record_id)

    @email_action.record or begin
      if signed_in?
        redirect_to root_url(danger: 'You are not authorized to take that action')
        return
      end
      raise 'unable to take action'
    end

    if @email_action.requires_user_to_be_signed_in? && !signed_in?
      user = threadable.users.find_by_id(user_id)

      if user.secure_mail_buttons?
        render :pending
        return
      end
    end

    @email_action.execute!

    if signed_in?
      redirect_to @email_action.redirect_url(self)
    else
      render :success
    end
  end

end
