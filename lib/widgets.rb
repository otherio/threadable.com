class Widgets

  def self.all
    Dir[Rails.root.join('app/widgets/*.rb')].
      map{|path| path[%r{/([^/]+)_widget.rb$}, 1] }.
      compact.
      map{|name| get(name) }
  end

  def self.get name
    name = name.to_s
    require Rails.root.join("app/widgets/#{name.underscore}_widget.rb")
    "::#{name.camelize}Widget".constantize
  end

  def self.render name, view, *arguments, &block
    # I have no idea why I need to do this sometimes
    view.class.send :include, Haml::Helpers unless view.class.include? Haml::Helpers
    view.init_haml_helpers if view.send(:haml_buffer).nil?
    # end of bug fix
    get(name).render(view, *arguments, &block)
  end

  def self.generate_sass!
    Rails.root.join('app/assets/stylesheets/_widgets.sass').open('w') do |file|
      with_sass.each do |widget|
        file.write %(.#{widget.classname}\n  @import "widgets/#{widget.classname}"\n)
      end
    end
  end

  def self.with_sass
    all.find_all{|widget| widget.paths.sass.exist? }
  end

end

require File.expand_path('../widgets/base', __FILE__)
