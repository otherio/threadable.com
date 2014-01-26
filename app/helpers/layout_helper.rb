module LayoutHelper

  def page_name
    "#{controller_name}/#{action_name}"
  end

  def javascript_env
    @javascript_env ||= {
      application_js_url: asset_url('application.js'),
      google_analytics_tracking_id: ENV['COVERED_GOOGLE_ANALYTICS_TRACKING_ID'].to_s,
      mixpanel_token: ENV['MIXPANEL_TOKEN'].to_s,
      flash: flash,
      page_name: page_name,
      current_user: current_user,
      current_organization: current_organization,
      current_conversation: current_conversation,
      current_task: current_task,
      current_task_doers: current_task.try(:doers).try(:all),
    }
  end

end
