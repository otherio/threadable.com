class Covered::Operations

  include Covered::Dependant

  def self.define name, &block
    const_set name.to_s.camelize, Class.new(Covered::Operation, &block)
    define_method(name){ |options={}|
      self.class[name].call({covered: covered}.merge(options))
    }
  end

  def self.[] name
    name = name.to_s.camelize
    operation = const_get(name, false)
  rescue NameError => e
    nil
  end

  def respond_to? method, include_all=false
    !!self.class[method] or super
  end

  def method_missing method, *args
    return public_send(method, *args) if respond_to? method
    super
  end

end
