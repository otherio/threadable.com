class Threadable::Collection

  include Let

  def initialize threadable
    @threadable = threadable
  end
  attr_reader :threadable

  def count
    record_counts = scope.count
    record_counts.is_a?(Hash) ? record_counts.count : record_counts
  end

  def inspect
    %(#<#{self.class}>)
  end

  def as_json options=nil
    all.as_json(options)
  end

end
