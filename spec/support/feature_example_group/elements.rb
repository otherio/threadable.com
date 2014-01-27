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

  def fill_in_element selector, options
    return if options[:with].blank?
    page.execute_script %{
      $('#{selector}').html("#{options[:with].gsub(/"/, '\"').gsub(/\n/, '\n')}");
      $('#{selector}').keydown();
      $('#{selector}').keyup();
    }
  end

end
