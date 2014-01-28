class OldEmailActionsController < ApplicationController

  def ill_do_it
    @action = 'add'
    execute!
  end

  def remove_me
    @action = 'remove'
    execute!
  end

  def mark_as_done
    @action = 'done'
    execute!
  end

  def mark_as_undone
    @action = 'undone'
    execute!
  end

  def mute
    @action = 'mute'
    execute!
  end

  private

  def execute!
    email_action.execute!
    redirect_to conversation_url(organization, 'my', conversation, success: email_action.description)
  end

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id])
  end

  def conversation
    @conversation ||= organization.conversations.find_by_slug!(params[:conversation_id])
  end

  def email_action
    @email_action ||= EmailAction.new(@action, current_user, conversation)
  end

end
