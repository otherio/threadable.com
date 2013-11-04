class Covered::Users < Covered::Resource

  def create options
    scope.create(options)
  end

  def find options
    scope.where(options)
  end

  def get options
    find(slug: options.fetch(:slug)).first or raise Covered::RecordNotFound
  end

  def new
    scope.new
  end

  private

  def scope
    Covered::User
  end

end
