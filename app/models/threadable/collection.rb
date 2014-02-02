class Threadable::Collection

  include Let

  def initialize threadable
    @threadable = threadable
  end
  attr_reader :threadable

  def count
    scope.count
  end

  def inspect
    %(#<#{self.class}>)
  end

  def as_json options=nil
    all.as_json(options)
  end

end
