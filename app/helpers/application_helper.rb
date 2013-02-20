  module ApplicationHelper

  def current_project
    @project
  end

  def current_conversation
    @conversation
  end

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end
end


