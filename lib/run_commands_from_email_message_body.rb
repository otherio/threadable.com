class RunCommandsFromEmailMessageBody < MethodObject

  def call conversation, body
    @conversation = conversation
    @body = body

    possible_commands.each do |command|
      execute! command
    end
  end

  private

  def possible_commands
    lines = @body[0..1024].split(/\n/)
    lines.take_while do |line|
      line !~ /^\s*&/ ? nil : line
    end
  end

  def execute! command
    case command
    when /^&done/i
      return unless @conversation.task?
      @conversation.done! if @conversation.task?
    when /^&undone/i
      return unless @conversation.task?
      @conversation.undone! if @conversation.task?
    when /^&mute/i
      @conversation.mute!
    when /^&unmute/i
      @conversation.unmute!
    when /^&follow/i
      @conversation.follow!
      @conversation.sync_to_user @conversation.threadable.current_user
    when /^&unfollow/i
      @conversation.unfollow!
    when /^&add(.*)/i
      return unless @conversation.task?
      doer = @conversation.organization.members.fuzzy_find($1)
      return unless doer.present?
      @conversation.doers.add(doer)
    when /^&remove(.*)/i
      return unless @conversation.task?
      doer = @conversation.organization.members.fuzzy_find($1)
      return unless doer.present?
      @conversation.doers.remove(doer)
    else
      return
    end
  end

end
