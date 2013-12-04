class Covered::Tasks::Create < MethodObject

  def call tasks, options
    tasks.covered.conversations.create(options.merge(task:true))
  end

end
