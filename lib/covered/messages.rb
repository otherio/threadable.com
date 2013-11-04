class Covered::Messages < Covered::Resource

  action :find do |options|
    scope.where(options).first!
  end

  action :get do |options|
    find(id: options.fetch(:id))
  end

  action :create

  action :update

  private

  def scope
    current_user.project_messages
  end

end
