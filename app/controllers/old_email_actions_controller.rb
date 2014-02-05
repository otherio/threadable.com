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
    redirect_to email_action.redirect_url(self)
  end

  def email_action
    @email_action ||= EmailAction.new(threadable, @type, current_user.id, params[:conversation_id])
  end

end
