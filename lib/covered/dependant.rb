module Covered::Dependant

  def initialize covered
    self.covered = covered
  end

  def inspect
    %(#<#{self.class} #{covered.env.inspect}>)
  end

  module AccessorMethods

    attr_reader :covered

    def covered= covered
      Covered::Class === covered or raise ArgumentError, "expected covered to be a Covered::Class"
      @covered = covered
    end
    private :covered=

  end

  include AccessorMethods

  module ClassMethods

    def dependant *dependants
      dependants.each do |dependant|
        method_name = dependant.to_s.underscore
        class_name  = dependant.to_s.camelize
        define_method dependant do
          return instance_variable_get("@#{method_name}") if instance_variable_get("@#{method_name}").present?
          instance_variable_set("@#{method_name}", Covered.const_get(class_name, false).new(self))
        end
      end
    end

  end

end
