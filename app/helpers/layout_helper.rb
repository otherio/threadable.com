module LayoutHelper

  def layout_wrapper(&block)
    render layout: "layouts/wrapper", &block
  end

  def page_name
    "#{controller_name}/#{action_name}"
  end

  def javascript_env
    @javascript_env ||= {
      flash: flash,
      pageName: page_name,
      currentProject: current_project,
      currentConversation: current_conversation,
      currentTask: current_task,
      currentTaskDoers: current_task ? current_task.doers : nil,
      currentUser: current_user,
    }
  end

end
