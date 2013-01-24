require "html_options"

class HtmlOptions::Classnames < Set

  def initialize(enum = nil, &block)
    super(split(enum), &block)
  end

  def to_s
    self.to_a.sort.join(' ')
  end
  alias_method :to_str, :to_s

  [
    :replace, :superset?, :proper_superset?, :subset?, :proper_subset?, :<<, :add?,
    :delete, :delete?, :subtract, :|, :+, :union, :-, :difference, :&, :intersection,
    :==, :eql?, :*, :exclude?
  ].each do |method|
    define_method method do |classnames|
      super self.class.new(classnames)
    end
  end

  def inspect
    %(HtmlOptions::Classnames[#{to_s.inspect}])
  end

  private

  def to_classnames classnames
    self.class.new(classnames)
  end

  def split classnames
    Array(classnames).flatten.map{ |c| c.to_s.split(/\s+/) }.flatten
  end

end
