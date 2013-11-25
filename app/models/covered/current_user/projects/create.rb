class Covered::CurrentUser::Projects::Create < MethodObject

  def call options
    @current_user = options.fetch(:current_user)
    @attributes   = options.fetch(:attributes)

    ::Project.transaction do
      @project = Covered::CurrentUser::Project.new(
        covered: @covered,
        project: ::Project.create(@attributes)
      )
      @project.members.add @covered.current_user if @project.persisted?
    end
    return @project # unless @project.persisted?
  end

end
