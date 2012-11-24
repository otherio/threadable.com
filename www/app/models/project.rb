class Project

  include Model

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
