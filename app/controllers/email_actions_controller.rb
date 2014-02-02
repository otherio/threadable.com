class EmailActionsController < ApplicationController

  include ForwardGetRequestsAsPostsConcern

  skip_before_action :require_user_be_signed_in!

  def show
    forward_get_requests_as_posts!
  end

  def take
    conversation_id, user_id, action = EmailActionToken.decrypt(params[:token])

    @user = signed_in? ? current_user : threadable.users.find_by_id(user_id) or begin
      return render :failed
    end

    @conversation = @user.conversations.find_by_id(conversation_id) or begin
      if signed_in?
        redirect_to root_url(danger: 'You are not authorized to take that action')
      else
        raise 'unable to take action'
      end
      return
    end

    @email_action = EmailAction.new(action, @user, @conversation)

    if signed_in?
      @email_action.execute!
      redirect_to conversation_url(@conversation.organization, 'my', @conversation, success: @email_action.description)
      return
    end

    render :pending
  end

end
