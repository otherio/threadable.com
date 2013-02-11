class TaskMetadataWidget < Widgets::Base

  def init conversation
    locals[:conversation] = conversation
  end

end
