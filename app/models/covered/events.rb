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

  def build attributes={}
    event_for scope.build(attributes)
  rescue ActiveRecord::SubclassNotFound
    raise ArgumentError, "unknown even type found in #{attributes.inspect}"
  end
  alias_method :new, :build


  private

  def scope
    ::Event.all
  end

  def event_for event_record
    event_type = event_record.type || 'Event'
    "Covered::#{event_type}".constantize.new(covered, event_record)
  end

end
