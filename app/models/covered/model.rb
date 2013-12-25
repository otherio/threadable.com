class Covered::Model

  include Let

  class << self
    def model_name
      return @model_name if @model_name
      superclass.model_name if superclass.respond_to?(:model_name)
    end
    private
    attr_writer :model_name
  end

  attr_reader :covered

  def inspect
    %(#<#{self.class}>)
  end

  def ==(other)
    super ||
      other.instance_of?(self.class) &&
      id.present? &&
      other.id == id
  end

  def eql? other
    self == other
  end

  # this returns the same hash for objects that represent the same record
  # this enables things like: `covered.users.all - [current_user]'
  def hash
    id.hash
  end

  # does not return any json by default, to prevent circular references.
  def as_json options=nil
    {}
  end

end
