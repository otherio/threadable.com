module CapybaraEnvironment::Wysiwyg

  def fill_in_wysiwyg value
    page.execute_script <<-JS
      $('.wysihtml5-sandbox:first').contents().find("body").html(#{value.inspect});
    JS
  end

end