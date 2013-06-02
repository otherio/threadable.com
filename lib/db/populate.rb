class Db::Populate < MethodObject

  def call
    # Other accounts
    developers =  YAML.load(Rails.root.join('config/developers.yml').read)

    developers.map do |name|
      first, last = name.scan(/^(.+?) (.+)/).first
      email = "#{first.downcase}@other.io"
      user = User.find_by_email(email) || User.create!(
        email: email,
        name: name,
        password: 'password',
      )
      user.confirm!
      user
    end

  end

end
