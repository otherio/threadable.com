class EmailAction

  InvalidType = Class.new(ArgumentError)
  AlreadyExecuted = Class.new(StandardError)

  TYPES = %w{
    done
    undone
    mute
    add
    remove
    join
    leave
  }.freeze

  def initialize threadable, type, user_id, record_id
    @threadable, @type, @user_id, @record_id = threadable, type.to_s, user_id, record_id
    raise InvalidType, "expected one of: #{TYPES.inspect}. Got: #{@type.inspect}" if TYPES.exclude?(@type)
  end

  attr_reader :threadable, :type, :user_id, :record_id, :conversation

  def user
    @user ||= threadable.current_user || threadable.users.find_by_id(@user_id)
  end

  def record
    return @record if @record
    thing = user || threadable
    @record = case @type
    when 'done';   thing.tasks.find_by_id(@record_id)
    when 'undone'; thing.tasks.find_by_id(@record_id)
    when 'mute';   thing.conversations.find_by_id(@record_id)
    when 'add';    thing.tasks.find_by_id(@record_id)
    when 'remove'; thing.tasks.find_by_id(@record_id)
    when 'join';   thing.groups.find_by_id(@record_id)
    when 'leave';  thing.groups.find_by_id(@record_id)
    end
  end

  def requires_user_to_be_signed_in?
    case @type
    when 'done';   true
    when 'undone'; true
    when 'mute';   true
    when 'add';    true
    when 'remove'; true
    when 'join';   false
    when 'leave';  false
    end
  end

  def opposite_type
    case @type
    when 'done';   'undone'
    when 'undone'; 'done'
    when 'mute';   nil # 'unmute'
    when 'add';    'remove'
    when 'remove'; 'add'
    when 'join';   'leave'
    when 'leave';  'join'
    end
  end

  def executed?
    !!@executed
  end

  def execute!
    raise AlreadyExecuted if executed?
    case type
    when 'done'
      record.done!
    when 'undone'
      record.undone!
    when 'mute'
      record.mute_for(user)
    when 'add'
      record.doers.add(user)
    when 'remove'
      record.doers.remove(user)
    when 'join'
      record.members.add(user)
    when 'leave'
      record.members.remove(user)
    end
    @executed = true
    threadable.track_for_user(@user_id, 'Email action taken',
      type:      @type,
      record_id: @record_id,
    )
  end

  def pending_description
    case type
    when 'done'
      "mark #{record.subject.inspect} as done"
    when 'undone'
      "mark #{record.subject.inspect} as not done"
    when 'mute'
      "mute #{record.subject.inspect}"
    when 'add'
      "add yourself as a doer of #{record.subject.inspect}"
    when 'remove'
      "remove yourself as a doer of #{record.subject.inspect}"
    when 'join'
      "add yourself to the #{record.name.inspect} group"
    when 'leave'
      "remove yourself from the #{record.name.inspect} group"
    end
  end

  def success_description
    case type
    when 'done'
      "You marked #{record.subject.inspect} as done"
    when 'undone'
      "You marked #{record.subject.inspect} as not done"
    when 'mute'
      "You muted #{record.subject.inspect}"
    when 'add'
      "You're added as a doer of #{record.subject.inspect}"
    when 'remove'
      "You're no longer a doer of #{record.subject.inspect}"
    when 'join'
      "You're now a member of the #{record.name.inspect} group"
    when 'leave'
      "You're no longer a member of the #{record.name.inspect} group"
    end
  end

  def redirect_url routes
    case type
    when 'done'
      routes.task_url(record.organization, 'my', record, success: success_description)
    when 'undone'
      routes.task_url(record.organization, 'my', record, success: success_description)
    when 'mute'
      routes.conversation_url(record.organization, 'my', record, success: success_description)
    when 'add'
      routes.task_url(record.organization, 'my', record, success: success_description)
    when 'remove'
      routes.task_url(record.organization, 'my', record, success: success_description)
    when 'join'
      routes.conversations_url(record.organization, record, success: success_description)
    when 'leave'
      routes.conversations_url(record.organization, record, success: success_description)
    end
  end

  def example_command
    case type
    when 'add', 'remove'
      %(&#{type} #{user ? user.name : 'Your Name'})
    else
      %(&#{type})
    end
  end

end
