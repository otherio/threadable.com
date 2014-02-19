class CorrectHtml < MethodObject
  def call body
    Nokogiri::HTML::DocumentFragment.parse(body).to_html
  end
end
