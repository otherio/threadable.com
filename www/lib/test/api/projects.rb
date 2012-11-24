module Test::Api::Projects

  extend Test::Api::Resources

  def self.create attributes
    attributes[:slug] ||= attributes[:name].gsub(' ','-').downcase
    super attributes
  end

  def self.find_by_id id
    all.find{|member| member[:id] == id }
  end

  def self.find_by_name name
    all.find{|member| member[:name] == name }
  end

  def self.find_by_slug slug
    all.find{|member| member[:slug] == slug }
  end

end
