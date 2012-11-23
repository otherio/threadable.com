class Api::Project

  include Virtus

  attributes

  def self.create attributes
    @projects ||= []
    @projects << attributes
  end

  def self.find name
    @projects.find{|project|
      project[:name] == name
    }
  end

end
