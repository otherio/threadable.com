class Covered::Conversations < Covered::Resource

  action :find

  action :update do |options|
    get(slug: options[:slug]).update_attributes(options[:attributes])
  end

  action :create

  private

  def scope
    @scope ||= current_user.conversations
  end

end
