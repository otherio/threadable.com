FixtureBuilder.build do

  [
    ['Jared Grippe',    'jared@other.io'],
    ['Nicole Aptekar',  'nicole@other.io'],
    ['Ian Baker',       'ian@other.io'],
    ['Aaron Muszalski', 'aaron@other.io'],
  ].each do |(name, email_address)|
    covered.users.create!(
      name: name,
      email_address: email_address,
      admin: true,
      password: 'password',
      password_confirmation: 'password',
    )
  end

end
