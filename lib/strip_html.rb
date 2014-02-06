class StripHtml < MethodObject

  def call html
    return if html.nil? || html === false
    html = html.to_s.gsub(%r{<br/?>}, "\n")
    html = Sanitize.clean html
    html = HTMLEntities.new.decode html
    html.strip.gsub(/\s+/, ' ')
  end

end
