require_dependency "#{Rails.root}/app/models/conversation"

class Conversation::Event < Event

  attr_accessible :conversation

  belongs_to :conversation

end
