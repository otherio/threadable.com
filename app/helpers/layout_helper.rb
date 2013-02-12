module LayoutHelper

  def layout_wrapper(&block)
    render layout: "layouts/wrapper", &block
  end

  def page_name
    "#{controller_name}/#{action_name}"
  end

  def javascript_env
    @javascript_env ||= {
      page_name: page_name,
      project: @project,
    }
  end

end
