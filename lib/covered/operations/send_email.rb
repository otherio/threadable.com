Covered::Operations.define :send_email do

  option :type,    required: true
  option :options, default: {}

  def call
    covered.generate_email(type: type, options: options).deliver!
  end

end
