module ApplicationHelper

  def current_project
    @project
  end

  def current_conversation
    @conversation
  end

  def current_task
    if @conversation && @conversation.task?
      return @conversation
    else
      return nil
    end
  end

  def timeago(time, html_options={})
    return unless time.respond_to? :getutc
    html_options = HtmlOptions.new(html_options)
    html_options.add_classname "timeago"
    html_options[:datetime] = time.getutc.iso8601
    content_tag(:time, '', html_options)
  end

  def strong *args
    content_tag(:strong, *args)
  end

end


