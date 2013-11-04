class Covered::Projects < Covered::Resource

  action :find

  action :new do |options={}|
    scope.new
  end

  action :create

  action :update do |options|
    get(slug: options[:slug]).update_attributes(options[:attributes])
  end

  private

  def scope
    current_user.projects
  end

end
