require_dependency "#{Rails.root}/app/models/conversation"

class Conversation::Event < Event

  belongs_to :conversation

end
