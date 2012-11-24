module Test::Api::Resources

  def all
    @all ||= []
  end

  def reset!
    @all = []
  end

  def create attributes
    attributes[:id] = all.length
    all << attributes
    attributes
  end

  def update attributes
    find_by_id(attributes[:id]).replace(attributes)
    attributes
  end

end
