  module ApplicationHelper

  def current_project
    @project
  end

  def current_conversation
    @conversation
  end

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:time, '', options.merge(:datetime => time.getutc.iso8601)) if time
  end
end


