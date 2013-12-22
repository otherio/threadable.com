module Fixtures

  def self.create_admins!
    [
      ['Jared Grippe',    'jared@other.io' ],
      ['Nicole Aptekar',  'nicole@other.io'],
      ['Ian Baker',       'ian@other.io'   ],
      ['Aaron Muszalski', 'aaron@other.io' ],
    ].each do |name, address|
      ::User.create!(
        name: name,
        admin: true,
        password: 'password',
        password_confirmation: 'password',
        email_addresses: [
          ::EmailAddress.create!(
            address: address,
            confirmed_at: Time.now,
            primary: true
          )
        ],
      )
    end
  end

  def self.delete!
    ActiveRecord::FixtureBuilder.config.fixtures_path.children.each do |child|
      child.delete if child.basename.to_s =~ /\.yml/
    end
  end

  def self.empty_databases!
    Covered.redis.flushdb
    ActiveRecord::FixtureBuilder.database.truncate_all_tables!
  end

  def self.build!
    delete!
    empty_databases!
    create_admins!
    ActiveRecord::FixtureBuilder.builders.each(&:build!)
    ActiveRecord::FixtureBuilder.write_fixtures!
  end

  def self.load!
    empty_databases!
    ActiveRecord::FixtureBuilder.load_fixtures!
  end

end
