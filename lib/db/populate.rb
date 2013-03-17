class Db::Populate < MethodObject

  def call
    # Other accounts
    developers =  YAML.load(Rails.root.join('config/developers.yml').read)

    developers.each do |name|
      first, last = name.scan(/^(.+?) (.+)/).first
      email = "#{first.downcase}@other.io"
      User.find_by_email(email) or User.create(
        email_addresses: [EmailAddress.new(address: email)],
        name: name,
        password: 'password',
      )
    end
  end

end
