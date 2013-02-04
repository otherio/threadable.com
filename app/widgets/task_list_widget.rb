class TaskListWidget < Widgets::Base

  def init tasks
    locals[:tasks] = tasks
  end

end
