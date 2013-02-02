# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Other accounts
["Jared Grippe", "Nicole Aptekar", "Ian Baker", "Aaron Muszalski"].each do |name|
  first, last = name.split(/\s+/)
  User.create!(
    email: "#{first.downcase}@other.io",
    name: name,
    password: 'password',
  )
end

# to duplicate the data in the mocks
raceteam = Project.create!(
  name: 'UCSD Electric Racing',
  description: 'Senior engineering electric race team!'
)

users = {}
["Alice Neilson", "Tom Canver", "Yan Hzu", "Bethany Pattern", "Bob Cauchois"].each do |name|
  first, last = name.split(/\s+/)
  user = User.create!(
    email: "#{first.downcase}@other.io",
    name: name,
    password: 'password',
  )

  raceteam.project_memberships.create!(user: user)
  users[first.to_sym] = user
end

# list of conversations
['layup body carbon',
'install mirrors',
'trim body panels',
'make wooden form for carbon layup',
'mount body on frame',
'install body clips',
'How are we going to build the body?',
'get mirrors',
'get epoxy',
'get release agent',
'get carbon and fiberglass'].each do |subject|
  raceteam.conversations.create!(subject: subject)
end

def generate_message_id
  'your-fantasy-message-id@example.com'
end

# list of messages in a single conversation
last_message = nil
conversation = raceteam.conversations.where(subject: 'layup body carbon').first
[
  {
    body: "Some stuff about how we have decided on a course of action for this body.\nSo, let's do some carbon layup!",
    user: users[:alice],
    reply: false
  },
  {
    body: "Totally!\nI'm thinking we can do this on our first January workday. I'll make sure we get the supplies in time",
    user: users[:tom],
    reply: true
  },
  {
    body: "I'm so there! Also, I think I can probably pick up some of those supplies from a friend, who was trying to make a kayak.",
    user: users[:yan],
    reply: true
  },
  {
    body: "So, I've got a question: we're using two layers of carbon with a layer of fiberglass between them for the bottom body panel, but do we want to do the same for the top? It doesn't need to be as strong, and less fiberglass would be lighter, but will it crack?",
    user: users[:tom],
    reply: true
  },
  {
    body: "I think I can get in touch with Yan's friend who built the carbon kayak.  He might know!",
    user: users[:alice],
    reply: true
  },
  {
    body: "Hey all! This looks pretty neat. Lets see if I can help you out here...\nSo on the kayak, we use two layers of carbon plus some batting on the bottom, and carbon/glass on the sides. Looking at the drawings on your blog, it seems like the top of the bodywork has a pretty wide unsupported area. In that case, I'd go for the carbon/glass, even though it's a little heavier. You could also use single layers of carbon and back it with some rod or some aluminum to reduce flexing and make it less likely to crack.\nGood luck!\nAndy",
    user: nil,
    from: '"Andy Lee Issacson" <andy@example.com>',
    reply: true
  },
  {
    body: "Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass like you suggested, since we're under weight on the wheels anyway.",
    user: users[:tom],
    reply: true
  },
  {
    body: "This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of them before they went in. Bethany got epoxy everywhere! It was pretty funny.",
    user: users[:tom],
    reply: true
  },

].each do |message_hash|
  # TODO: populate children
  message = conversation.messages.create(message_hash.merge({
    subject: 'layup body carbon',
    parent_message: message_hash[:reply] ? last_message : nil,
    message_id_header: generate_message_id
  }))
  last_message = message
end

