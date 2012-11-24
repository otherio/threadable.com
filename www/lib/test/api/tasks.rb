module Test::Api::Tasks

  extend Test::Api::Resources

  def self.create attributes
    if attributes[:slug].blank?
      attributes[:slug] = attributes[:name].gsub(' ','-').downcase
    end
    super attributes
  end

  def self.find_by_id project_id, id
    all.find{|member|
      member[:project_id] == project_id.to_i && member[:id] == id
    }
  end

  def self.find_by_name project_id, name
    all.find{|member|
      member[:project_id] == project_id.to_i && member[:name] == name
    }
  end

  def self.find_by_slug project_id, slug
    all.find{|member|
      member[:project_id] == project_id.to_i && member[:slug] == slug
    }
  end

  def self.update attributes
    find_by_id(attributes[:project_id], attributes[:id]).replace(attributes)
    attributes
  end

end
