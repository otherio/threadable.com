FixtureBuilder.build do

  as_an_admin do
    create_organization(
      name: 'Other Admins',
      short_name: 'adminteam',
      description: 'For some fucking reason we have a description!',
    )
    add_member 'Jared Grippe', 'jared@other.io'
  end

  web_enable! 'jared@other.io'
  as 'jared@other.io' do
    # Jared invites her organization mates
    add_member 'Nicole Aptekar',  'nicole@other.io'
    add_member 'Aaron Muszalski', 'aaron@other.io'
    add_member 'Ian Baker',       'ian@other.io'

    # Jared sends a welcome email
    @welcome_message = create_conversation(
      subject: 'Holy fuck',
      text: "Hey all! You're admins!",
    )
  end
end
