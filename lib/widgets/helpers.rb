module Widgets::Helpers

  def render_widget name, *args, &block
    Widgets.render(name, self, *args, &block)
  end

end
