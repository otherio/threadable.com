module EmailHelper

  def mail_to_href email_address, options={}
    email_address = ERB::Util.html_escape(email_address)

    options = (options || {}).stringify_keys

    extras = %w{ cc bcc body subject }.map { |item|
      option = options.delete(item) || next
      "#{item}=#{Rack::Utils.escape_path(option)}"
    }.compact
    extras = extras.empty? ? '' : '?' + extras.join('&')

    "mailto:#{email_address}#{extras}".html_safe
  end

end
