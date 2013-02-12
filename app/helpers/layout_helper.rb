module LayoutHelper

  def layout_wrapper(&block)
    render layout: "layouts/wrapper", &block
  end

  def page_name
    "#{controller_name}/#{action_name}"
  end

  def javascript_env
    @javascript_env ||= {
      pageName: page_name,
      currentProject: current_project,
      currentConversation: current_conversation,
    }
  end

end
