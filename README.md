# Multify

## Things...

review existing scenarios (possibly update)
order them scenarioes by importance AKA build order
make tracker stories and chores
work on stories


TASKS:
setup basic rails app on heroku with assets and a worker
setup basic travis CI system
spike using http://postmarkapp.com
build personas and fixture data diagrams



***** in tracker
MVP "the new charmander"
- make a task @tasks
- complete a task @tasks
- make a conversation @conversations
- see all finished tasks @tasks
- list and open conversations @conversations
- view a conversation @conversations
- get an email when a message is posted @conversations
- post a message to a conversation via www @conversations
- post a message to a conversation via email @conversations
- sort tasks by fancy! (dragging is fancy) @tasks
- add & remove doers to a task @tasks
- see my tasks vs all tasks @tasks
- invite people to the project @tasks
- display conversation events in www @conversations

MVP+ "i hate and love your stuff"
- mute a conversation
- make a task from within a conversation @conversations
- link a task or conversation to an existing conversation
- fuzzy filter input box for tasks and conversations

MVP++ "who the fuck am i talking to"
- get gravatar or google avatar or whatever wgaf
- track read messages in a conversation @conversations
- collapse read messages in the conversation view page
- view unread messages in task list

MVP+++ "Ideas Worth Sharing"
- mark a message as sharable
- mark a message as knowledge
- post a photo(s) to a conversation
- add events to conversations
- mark only part of a message as sharable
- mark only part of a message as knowledge
- the entire story editor page
- also the entire public page
- also crowdfunding campaigns, aka what people will be giving us money for

MVP++++ "Post-funding openness"
- make a project
- set the subject line thing for the project
- see a member list page
- see calendar
- make the event thing like doodle
- see who muted a conversation maybe

SKY
- subprojecty context things
- have a fuckin ical feed
- get voting for things in somehow

MOON
- per-user subject prefix



## Schema


users
• id                Integer
• slug              String

projects
• id                Integer
• slug              String

project_memberships
• project_id        Integer
• user_id           Integer

conversations
• id                Integer
• project_id        Integer
• slug              String

muted_conversations
• user_id           Integer
• conversation_id   Integer

messages
• id                Integer
• conversation_id   Integer
• message_id        String
• parent_message_id Integer
• children          String (serialized array)
• subject           String
• reply             Boolean
• body              Blob

tasks
• id                Integer
• project_id        Integer
• conversation_id   Integer
• complete          Boolean

task_doers
• user_id           Integer
• task_id           Integer

conversation_events
• id                Integer
• conversation_id   Integer
• type              Integer
• body              String
