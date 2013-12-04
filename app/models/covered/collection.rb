class Covered::Collection

  include Let
  extend ActiveSupport::Autoload

  def initialize covered
    @covered = covered
  end
  attr_reader :covered

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
