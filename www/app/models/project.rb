class Project

  include Model

  def self.find_by_id *args
    new Api::Projects.find_by_id(*args)
  end

  def self.find_by_name *args
    new Api::Projects.find_by_name(*args)
  end

  def self.find_by_slug *args
    new Api::Projects.find_by_slug(*args)
  end


  attribute :id, Integer
  attribute :name, String
  attribute :slug, String
  attribute :description, String

  def to_param
    slug
  end

  def tasks
    @tasks ||= Project::Tasks.new(self)
  end

  def followers
    @followers ||= Followers.new(self)
  end

  # def members
  #   @members ||= Members.new(self)
  # end

end
