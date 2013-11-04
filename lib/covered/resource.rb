class Covered::Resource

  delegate :current_user, to: :covered

  extend ActiveSupport::Autoload
  include Covered::Dependant

  def self.action action, &block

    if !block_given?
      classname = action.to_s.camelize
      autoload classname
      block = ->(options={}){
        self.class.const_get(classname, false).call options.merge(resource: self)
      }
    end

    define_method(action, &block)

    # define_method(action) do |options={}|
    #   begin
    #     instance_exec(options, &block)
    #   rescue ActiveRecord::RecordNotFound
    #     raise Covered::RecordNotFound
    #   end
    # end

  end

  action :all do
    find
  end

  action :get do |options|
    find options.merge(first: true)
  end

  private

  def scope
    raise 'subclass should define #scope'
  end

  def where conditions
    @scope = scope.where(conditions)
  end

  def find_by_slug slug
    scope.where(slug: slug).first!
  rescue ActiveRecord::RecordNotFound
    raise Covered::RecordNotFound
  end

end
