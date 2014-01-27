class EmailAction

  InvalidType = Class.new(ArgumentError)
  AlreadyExecuted = Class.new(StandardError)

  TYPES = %w{
    done
    undone
    mute
    add
    remove
  }.freeze

  def initialize type, user, conversation
    @type, @user, @conversation = type.to_s, user, conversation
    raise InvalidType, "expected one of: #{TYPES.inspect}. Got: #{@type.inspect}" if TYPES.exclude?(@type)
  end

  attr_reader :type, :user, :conversation

  def executed?
    !!@executed
  end

  def execute!
    raise AlreadyExecuted if executed?
    @executed = true
    case @type
    when 'done'
      @conversation.done! if @conversation.task?
    when 'undone'
      @conversation.undone! if @conversation.task?
    when 'mute'
      @conversation.mute_for(@user)
    when 'add'
      @conversation.doers.add(@user)
    when 'remove'
      @conversation.doers.remove(@user)
    end
  end

  def pending_description
    case @type
    when 'done'
      "mark the conversation #{@conversation.subject.inspect} as done"
    when 'undone'
      "mark the conversation #{@conversation.subject.inspect} as not done"
    when 'mute'
      "mute the conversation #{@conversation.subject.inspect}"
    when 'add'
      "add yourself as a doer of the task #{@conversation.subject.inspect}"
    when 'remove'
      "remove yourself from the doers of the task #{@conversation.subject.inspect}"
    end
  end

  def description
    case @type
    when 'done'
      "we've marked #{@conversation.subject.inspect} as done"
    when 'undone'
      "we've marked #{@conversation.subject.inspect} as not done"
    when 'mute'
      "we've muted #{@conversation.subject.inspect} for you"
    when 'add'
      "we've added you as a doer of the task #{@conversation.subject.inspect}"
    when 'remove'
      "we've removed you from the doers of the task #{@conversation.subject.inspect}"
    end
  end

end
