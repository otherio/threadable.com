module Test::Api::Resources

  def all
    @all ||= []
  end

  def reset!
    @all = []
  end

  def count
    @all.size
  end

  def last
    @all.last
  end

  def destroy id
    @all.reject!{|member| member[:id] == id }
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
