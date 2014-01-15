module RSpec::Support::FeatureExampleGroup

  def find_element name
    find selector_for name
  end

  def within_element name, &block
    within(selector_for(name), &block)
  end

  def click_element name
    find_element(name).click
  end

end
