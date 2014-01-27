class EmailActionsController < ApplicationController

  include ForwardGetRequestsAsPostsConcern

  skip_before_action :require_user_be_signed_in!

  def show
    forward_get_requests_as_posts!
  end

  def take
    email_action or return render :failed
    return render :pending if !signed_in?
    email_action.execute!
    redirect_to conversation_url(@email_action.conversation.organization, 'my', @email_action.conversation, success: email_action.description)
  end

  private

  def email_action
    return @email_action if @email_action
    conversation_id, user_id, action = EmailActionToken.decrypt(params.require(:token))
    user         = covered.users.find_by_id!(user_id)
    conversation = covered.conversations.find_by_id!(conversation_id)
    @email_action = EmailAction.new(action, user, conversation)
  rescue Token::Invalid, EmailAction::InvalidType, Covered::RecordNotFound
    covered.report_exception!($!)
    nil
  end

end
