require 'rails/console/app'

module Rails::ConsoleMethods

  def covered options=nil
    @covered = nil if @covered && @covered.class != Covered::Class
    return @covered if options.nil? && @covered
    @covered = nil
    options ||= {}
    options[:current_user] ||= Covered::User.first!
    options[:host] ||= 'test-covered.io'
    options[:port] ||= 80
    @covered = Covered.new(options)
  end

  def reload_fixtures!
    CapybaraEnvironment.reload_fixtures!
  end

  # this doesnt persist into the next request :(
  def sign_in_as email
    app.post app.sign_in_path, {
      "authentication" => {
        "email"       => email,
        "password"    => "password",
      },
    }
  end

end
