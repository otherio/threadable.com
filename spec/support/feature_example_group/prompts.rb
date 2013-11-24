module RSpec::Support::FeatureExampleGroup

  def accept_prompt!
    case
    when page.driver.browser.respond_to?(:accept_js_prompts)
      page.driver.browser.accept_js_prompts
    when page.driver.browser.respond_to?(:switch_to)
      alert = page.driver.browser.switch_to.alert
      alert.accept
    else
      raise "current driver does not appear to support prompts"
    end
  end

end
