class Db::Populate < MethodObject

  def call
    # Other accounts
    developers =  YAML.load(Rails.root.join('config/developers.yml').read)

    developers.each do |name|
      first, last = name.scan(/^(.+?) (.+)/).first
      User.find_or_create_by_email(
        email: "#{first.downcase}@other.io",
        name: name,
        password: 'password',
      )
    end
  end

end
