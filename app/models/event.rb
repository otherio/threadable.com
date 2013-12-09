class Event < ActiveRecord::Base

  serialize :content, Hash

  belongs_to :project
  belongs_to :user

  validates_presence_of :project
  validates_presence_of :user

  default_scope { order :created_at => :asc }

end

# This forces all events to get loaded when Event is loaded
# which changes the sql queries that are run ::facepalm:: - jared
# require "conversation/event"
# require "conversation/created_event"
# require "task/event"
# require "task/created_event"
# require "task/done_event"
# require "task/undone_event"
# require "task/added_doer_event"
# require "task/removed_doer_event"


# Conversation.const_get(:Event, false)
# Conversation.const_get(:CreatedEvent, false)
# Task.const_get(:Event, false)
# Task.const_get(:CreatedEvent, false)
# Task.const_get(:CreatedEvent, false)
# Task.const_get(:DoneEvent, false)
# Task.const_get(:UndoneEvent, false)
# Task.const_get(:AddedDoerEvent, false)
# Task.const_get(:RemovedDoerEvent, false)
