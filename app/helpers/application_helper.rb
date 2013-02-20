  module ApplicationHelper

  def current_project
    @project
  end

  def current_conversation
    @conversation
  end

  def timeago(time, html_options={})
    return unless time.respond_to? :getutc
    html_options = HtmlOptions.new(html_options)
    html_options.add_classname "timeago"
    html_options[:datetime] = time.getutc.iso8601
    content_tag(:time, '', html_options)
  end
end


