class Covered::Events < Covered::Collection

  def all
    scope.reload.map{ |event| event_for event }
  end

  def latest
    event_for (scope.last or return)
  end

  def oldest
    event_for (scope.first or return)
  end

  def create event_type, attributes={}
    Create.call(self, event_type, attributes)
  end

  def create! event_type, attributes={}
    event = create(event_type, attributes)
    event.persisted? or raise Covered::RecordInvalid, "Event invalid: #{event.errors.full_messages.to_sentence}"
    event
  end

  private

  def scope
    ::Event.all
  end

  def event_for event_record
    return nil if event_record.nil?
    event_type = event_record.event_type.to_s.camelize
    "Covered::Events::#{event_type}".constantize.new(covered, event_record)
  end

end
