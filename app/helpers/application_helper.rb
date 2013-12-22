module ApplicationHelper

  def current_url
    request.url
  end

  def current_organization
    @organization
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

  def clean_html(html)
    Sanitize.clean(html.to_s, Sanitize::Config::RELAXED).html_safe
  end

  def htmlify(string)
    h(clean_html(auto_link(string.to_s))).gsub(/\n/, "<br/>").html_safe
  end

  def truncated_text text, length=25
    capture_haml do
      haml_tag :span, truncate(text.to_s, length: length), title: text.to_s
    end
  end

end


