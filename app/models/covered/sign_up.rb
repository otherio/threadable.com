class Covered::SignUp < MethodObject

  OPTIONS = Class.new OptionsHash do
    required :covered, :name, :email_address, :password, :password_confirmation
  end

  def call options
    options = OPTIONS.parse(options).to_hash
    @covered = options.delete(:covered)
    @covered.users.create options.to_hash
  end

end
