TestEnvironment::FixtureBuilder.new do

  # Data sampled from:
  # http://marsrover.nasa.gov/people/
  # http://marsrover.nasa.gov/journal/

  # John from NASA signs up
  create_user 'John Callas', 'john-callas@nasa.multifyapp.com'

  # Alice creates a project
  @project = Project.create!(
    name: 'Mars Exploration Rover',
    description: 'Put a robot on mars.',
  )
  project.members << user('John Callas')

  invite_user 'Bruce Banerdt',  'bruce-banerdt@nasa.multifyapp.com'
  invite_user 'Diana Blaney',   'diana-blaney@nasa.multifyapp.com'
  invite_user 'Larry Bryant',   'larry-bryant@nasa.multifyapp.com'
  invite_user 'Steven Squyres', 'steven-squyres@nasa.multifyapp.com'
  invite_user 'Ray Arvidson',   'ray-arvidson@nasa.multifyapp.com'

  users['Ray Arvidson'].email_addresses.create! address: 'ray@gmail.multifyapp.com'

  accept_invite 'Bruce Banerdt'
  accept_invite 'Diana Blaney'
  # accept_invite 'Larry Bryant' # he never accepted his invite
  accept_invite 'Steven Squyres'
  accept_invite 'Ray Arvidson'

  send_message(
    user: 'John Callas',
    reply: false,
    subject: 'Welcome everyone. Lets get started',
    body: %(I've invited all the managers. You're all welcome to add anyone you need.)
  )

  send_message(
    user: 'Ray Arvidson',
    reply: true,
    subject: 'RE: Welcome everyone. Lets get started',
    body: %(Thanks John. I'll get right on that.)
  )

end
