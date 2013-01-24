module Widgets::SassHelpers

  def widgets
    widgets_with_sass = Widgets.all.find_all{|widget| widget.paths.sass.exist? }
    widgets_with_sass.map!{|widget| Sass::Script::String.new(widget.classname) }
    Sass::Script::List.new(widgets_with_sass, :comma)
  end

end
