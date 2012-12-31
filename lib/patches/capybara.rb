# works for xpath-0.1.4 gem
module ::XPath::HTML

  # # these add :not([disabled]) to the xpath that looks for clickable links and buttons
  # def link_with_not_disabled(locator, options={})
  #   link_without_not_disabled(locator, options={})[attr(:disabled).inverse]
  # end
  # alias_method_chain :link, :not_disabled

  # def button_with_not_disabled(locator)
  #   button_without_not_disabled(locator)[attr(:disabled).inverse]
  # end
  # alias_method_chain :button, :not_disabled

protected

  # Adds placeholder to the XPath used to identify fields
  def locate_field(xpath, locator)
    locate_field = xpath[attr(:placeholder).equals(locator) | attr(:id).equals(locator) | attr(:name).equals(locator) | attr(:id).equals(anywhere(:label)[string.n.is(locator)].attr(:for))]
    locate_field += descendant(:label)[string.n.is(locator)].descendant(xpath)
  end
end
