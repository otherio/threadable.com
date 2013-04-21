module ApplicationHelper

  def current_project
    @project
  end

  def current_conversation
    @conversation
  end

  def current_task
    return @task if @task
    return @conversation if @conversation && @conversation.task?
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

  def humanize_time datetime
    ago = Time.now - datetime
    case
    when ago > 1.year
      datetime.strftime('%-m/%-d/%Y')
    when ago > 1.day
      datetime.strftime('%b %-d')
    else
      datetime.strftime('%l:%M %p')
    end
  end

end


