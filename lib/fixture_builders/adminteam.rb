FixtureBuilder.build do

  as_an_admin do
    create_organization(
      name: 'Other Admins',
      short_name: 'adminteam',
      description: 'For some fucking reason we have a description!',
    )
    add_member 'Ian Baker', 'ian@other.io'
  end

  web_enable! 'ian@other.io'
  as 'ian@other.io' do
    add_member 'Nicole Aptekar',  'nicole@other.io'
    add_member 'Ian Baker',       'ian@other.io'

    @welcome_message = create_conversation(
      subject: 'Holy fuck',
      text: "Hey all! You're admins!",
    )
  end
end
