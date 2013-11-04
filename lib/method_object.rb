# Usage:
#
#   class OpenChest < MethodObject
#
#     option :size,  default: 12
#     option :color, required: true
#
#     def call
#       [@size, color]
#     end
#
#   end
#
#   class OpenMagicChest < OpenChest
#
#     option :size, required: true
#     option :key_type, default: ->{ :upside }
#
#     def call
#       [size, color, @key_type]
#     end
#
#   end
#
#
class MethodObject

  class << self
    private :new

    def call options=nil
      new(options).call
    end

    def options
      @options ||= {}
      @options.reverse_merge superclass.respond_to?(:options) ? superclass.options : {}
    end

    def option name, details={}
      if details.has_key?(:required) && details.has_key?(:default)
        raise ArgumentError, "giving a default to a required option doesnt make any sense.", caller(2)
      end
      @options ||= {}
      @options[name] = details
      all_instance_methods = public_instance_methods + private_instance_methods + protected_instance_methods(false)
      attr_reader(name) unless all_instance_methods.include? :"#{name}"
      attr_writer(name) unless all_instance_methods.include? :"#{name}="
      self
    end
  end

  def call
    raise "#{self.class}#call is not defined"
  end

  def initialize options=nil
    process_options! options
  end

  private

  def process_options! options
    options = (options || {}).with_indifferent_access
    self.class.options.each do |name, details|

      if options.has_key?(name)
        send "#{name}=", options.delete(name)
        next
      end

      if details[:required]
        raise ArgumentError, "#{name} is a required option for #{self.class}", caller(4)
      end

      if default = details[:default]
        default = instance_exec(&default) if default.respond_to? :call
        send "#{name}=", default
      end

    end

    return if options.keys.empty?
    raise ArgumentError, "unknown options #{options.inspect}", caller(4)
  end

end
