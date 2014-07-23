class Threadable::Events < Threadable::Collection

  def all
    scope.reload.map{ |event| event_for event }
  end

  def latest
    event_for (scope.last or return)
  end
  alias_method :last, :latest

  def oldest
    event_for (scope.first or return)
  end
  alias_method :first, :oldest

  def create event_type, attributes={}
    Create.call(self, event_type, attributes)
  end

  def create! event_type, attributes={}
    event = create(event_type, attributes)
    event.persisted? or raise Threadable::RecordInvalid, "Event invalid: #{event.errors.full_messages.to_sentence}"
    event
  end

  private

  def scope
    ::Event.all
  end

  def event_for event_record
    return nil if event_record.nil?
    event_type = event_record.event_type.to_s.camelize
    "Threadable::Events::#{event_type}".constantize.new(threadable, event_record)
  end

end
