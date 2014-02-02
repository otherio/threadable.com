module LayoutHelper

  def page_name
    "#{controller_name}/#{action_name}"
  end

  def javascript_env
    @javascript_env ||= {
      google_analytics_tracking_id: ENV['THREADABLE_GOOGLE_ANALYTICS_TRACKING_ID'].to_s,
      mixpanel_token: ENV['MIXPANEL_TOKEN'].to_s,
    }
  end

end
