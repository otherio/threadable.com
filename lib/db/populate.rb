class Db::Populate < MethodObject

  def call
    # Other accounts
    developers =  YAML.load(Rails.root.join('config/developers.yml').read)

    developers.each do |name|
      first, last = name.scan(/^(.+?) (.+)/).first
      email = "#{first.downcase}@other.io"
      next if User.by_email(email).exists?
      User.create!(
        email: email,
        name: name,
        password: 'password',
      )
    end

  end

end
