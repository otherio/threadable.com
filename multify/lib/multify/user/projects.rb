class Multify::User::Projects < Multify::Resource::HasMany

  def initialize options={}
    super(Multify::Project, options)
  end

end
