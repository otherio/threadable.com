class StripHtml < MethodObject

  def call html
    return if html.nil?
    html = html.to_s.gsub(%r{<br/?>}, "\n")
    html = html.to_s.gsub(%r{(?<!\n)<div>}, "\n<div>")
    text = Sanitize.clean(html)
    text = HTMLEntities.new.decode text
    text = text.to_s.gsub(%r{\s*\n\s*}, "\n")
    text.strip
  end

end
