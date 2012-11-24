module Test::Api::Tasks

  extend Test::Api::Resources

  def self.create attributes
    if attributes[:slug].empty?
      attributes[:slug] = attributes[:name].gsub(' ','-').downcase
    end
    super attributes
  end

  def self.find_by_id project_id, id
    all.find{|member|
      member[:project_id] == project_id && member[:id] == id
    }
  end

  def self.find_by_name project_id, name
    all.find{|member|
      member[:project_id] == project_id && member[:name] == name
    }
  end

  def self.find_by_slug project_id, slug
    all.find{|member|
      member[:project_id] == project_id && member[:slug] == slug
    }
  end

end
