module LayoutHelper

  def layout_wrapper(&block)
    render layout: "layouts/wrapper", &block
  end

  def page_name
    "#{controller_name}/#{action_name}"
  end

  def javascript_env
    @javascript_env ||= {
      application_js_url: asset_url('application.js'),
      google_analytics_tracking_id: ENV['COVERED_GOOGLE_ANALYTICS_TRACKING_ID'].to_s,
      flash: flash,
      page_name: page_name,
      current_user: current_user,
      current_project: current_project,
      current_conversation: current_conversation,
      current_task: current_task,
      current_task_doers: current_task.try(:doers),
    }
  end

end
