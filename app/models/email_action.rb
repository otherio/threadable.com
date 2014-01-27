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
      "mark #{@conversation.subject.inspect} as done"
    when 'undone'
      "mark #{@conversation.subject.inspect} as not done"
    when 'mute'
      "mute #{@conversation.subject.inspect}"
    when 'add'
      "add yourself as a doer of #{@conversation.subject.inspect}"
    when 'remove'
      "remove yourself as a doer of #{@conversation.subject.inspect}"
    end
  end

  def description
    case @type
    when 'done'
      "You marked #{@conversation.subject.inspect} as done"
    when 'undone'
      "You marked #{@conversation.subject.inspect} as not done"
    when 'mute'
      "You muted #{@conversation.subject.inspect}"
    when 'add'
      "You're added as a doer of #{@conversation.subject.inspect}"
    when 'remove'
      "You're no longer a doer of #{@conversation.subject.inspect}"
    end
  end

end
