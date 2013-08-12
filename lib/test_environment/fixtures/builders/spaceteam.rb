TestEnvironment::FixtureBuilder.new do

  # Data sampled from:
  # http://marsrover.nasa.gov/people/
  # http://marsrover.nasa.gov/journal/

  # John from NASA signs up
  sign_up 'John Callas', 'john-callas@nasa.covered.io', 'password'

  # John creates a project
  @project = Project.create!(
    name: 'Mars Exploration Rover',
    short_name: 'Spaceteam',
    description: 'Put a robot on mars.',
  )
  project.members << user('John Callas')

  add_user 'Bruce Banerdt',  'bruce-banerdt@nasa.covered.io'
  add_user 'Diana Blaney',   'diana-blaney@nasa.covered.io'
  add_user 'Larry Bryant',   'larry-bryant@nasa.covered.io'
  add_user 'Steven Squyres', 'steven-squyres@nasa.covered.io'
  add_user 'Ray Arvidson',   'ray-arvidson@nasa.covered.io'

  users['Ray Arvidson'].email_addresses.create! address: 'ray@gmail.covered.io'

  web_enable 'Bruce Banerdt', 'password'
  web_enable 'Diana Blaney', 'password'
  # web_enable 'Larry Bryant' # he never accepted his invite, 'password'
  web_enable 'Steven Squyres', 'password'
  web_enable 'Ray Arvidson', 'password'

  send_message(
    user: 'John Callas',
    reply: false,
    subject: 'Welcome everyone. Lets get started',
    body_plain: %(I've invited all the managers. You're all welcome to add anyone you need.)
  )

  send_message(
    user: 'Ray Arvidson',
    reply: true,
    subject: 'RE: Welcome everyone. Lets get started',
    body_plain: %(Thanks John. I'll get right on that.)
  )

end
