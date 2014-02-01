module RSpec::Support::FeatureExampleGroup

  def resize_window_to size
    window = Capybara.current_session.driver.browser.manage.window
    case size.to_sym
    when :small
      window.resize_to(640, 960)
    when :medium
      window.resize_to(1024, 768)
    when :large
      window.resize_to(1280, 1024)
    else
      raise ArgumentError, "unknown window size #{size}"
    end
  end
end
