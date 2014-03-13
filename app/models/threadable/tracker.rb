class Threadable::Tracker

  def initialize threadable
    @threadable = threadable
  end

  attr_reader :threadable

  delegate :tracking_id, to: :threadable

  def inspect
    %(#<#{self.class}>)
  end

end
