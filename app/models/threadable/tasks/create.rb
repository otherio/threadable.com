class Threadable::Tasks::Create < MethodObject

  def call tasks, options
    tasks.threadable.conversations.create(options.merge(task:true))
  end

end
