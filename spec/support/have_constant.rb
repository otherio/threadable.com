RSpec::Matchers.define :have_constant do |constant|
  match do |_|
    @actual = @actual.class unless Module === @actual
    @constant_name = "#{@actual}::#{constant}"
    begin
      @constant = @actual.const_get(constant, false)
      @constant.name == @constant_name
    rescue NameError
      @uninitialized_constant = true
      false
    end
  end

  description do
    "have constant #{constant}"
  end

  failure_message do |text|
    @uninitialized_constant ?
      "expected #{@actual} to have constant #{constant}" :
      "expected #{@constant_name}.name to eq #{@constant_name}"
  end

  failure_message_when_negated do |text|
    "expected #{@actual} to not have constant #{constant}"
  end

end
