require_dependency 'event'
require_dependency 'conversation/created_event'
require_dependency 'conversation/event'
require_dependency 'task/event'
require_dependency 'task/added_doer_event'
require_dependency 'task/created_event'
require_dependency 'task/done_event'
require_dependency 'task/removed_doer_event'
require_dependency 'task/undone_event'

class Covered::Events::Create < MethodObject

  OPTIONS = Class.new OptionsHash do
    required :type, default: 'Event'
    optional :organization_id
    optional :conversation_id
    optional :content
  end

  def call events, options
    begin
      event_record = options[:type].constantize.create!(options)
      event = "Covered::#{options[:type]}".constantize.new(events.covered, event_record)
      events.covered.track(event.tracking_name, options.except(:type)) if event.persisted?
      event
    rescue ActiveRecord::SubclassNotFound
      raise ArgumentError, "unknown event type found in #{options.inspect}"
    end
  end

end
