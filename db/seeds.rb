# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


["Jared Grippe", "Nicole Aptekar", "Ian Baker", "Aaron Muszalski"].each do |name|
  first, last = name.split(/\s+/)
  User.create!(
    email: "#{first.downcase}@other.io",
    name: name,
    password: 'password',
  )
end
