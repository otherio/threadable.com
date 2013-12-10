class Covered::Model

  include Let

  class << self
    attr_reader :model_name
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
