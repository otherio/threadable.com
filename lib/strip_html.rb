class StripHtml < MethodObject

  def call html
    return if html.nil?
    html = html.to_s.gsub(%r{<br/?>}, "\n")
    html = Sanitize.clean html
    html = HTMLEntities.new.decode html
    html.strip
  end

end
