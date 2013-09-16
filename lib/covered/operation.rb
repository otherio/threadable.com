class Covered::Operation

  include Let

  class << self

    def call(options={}, &block)
      options = options.to_hash if options.respond_to?(:to_hash)
      unless options.is_a? Hash
        raise ArgumentError, "expected options to be a Hash but was a #{options.class}"
      end

      options.symbolize_keys!

      required_options.each do |required_option|
        next if options.has_key? required_option
        raise ArgumentError, "the #{required_option} option is required"
      end

      instance = new
      instance.instance_variable_set("@block", block)
      options.each do |key, value|
        instance.instance_variable_set("@#{key}", value)
      end


      instance.call(&block)
    end
    alias_method :[], :call

    def required_options
      @required_options ||= Set[]
      @super_required_options = superclass.respond_to?(:required_options) ?
        superclass.required_options : Set[]
      @required_options + @super_required_options
    end

    def required_options=(required_options)
      @required_options = required_options.map(&:to_sym).to_set
    end

    def require_option(*options)
      self.required_options += options.map(&:to_sym).to_set
    end

    private :new

  end

end
