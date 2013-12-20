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

  def == other
    self.class === other && other.id == id
  end

end
