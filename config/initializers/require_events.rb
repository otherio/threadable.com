# This forces all events to get loaded in the right order
# without this the event select quries can be incomplete ::facepalm:: - jared
require "event"                      or raise "failed to properly load events"
require "conversation/event"         or raise "failed to properly load events"
require "conversation/created_event" or raise "failed to properly load events"
require "task/event"                 or raise "failed to properly load events"
require "task/created_event"         or raise "failed to properly load events"
require "task/done_event"            or raise "failed to properly load events"
require "task/undone_event"          or raise "failed to properly load events"
require "task/added_doer_event"      or raise "failed to properly load events"
require "task/removed_doer_event"    or raise "failed to properly load events"
