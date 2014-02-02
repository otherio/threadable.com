class Threadable::Tracker

  def initialize threadable
    @threadable = threadable
  end
  attr_reader :threadable

  def inspect
    %(#<#{self.class}>)
  end

end
