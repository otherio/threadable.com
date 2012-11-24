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

  def find_by_id id
    all.find{|member| member[:id] == id }
  end

  def find_by_name name
    all.find{|member| member[:name] == name }
  end

  def find_by_slug slug
    all.find{|member| member[:slug] == slug }
  end

end
