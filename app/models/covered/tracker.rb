class Covered::Tracker

  def initialize covered
    @covered = covered
  end
  attr_reader :covered

  def inspect
    %(#<#{self.class}>)
  end

end
