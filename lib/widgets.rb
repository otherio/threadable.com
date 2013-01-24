class Widgets

  def self.all
    Dir[Rails.root.join('app/widgets/*.rb')].map do |path|
      get path[%r{/([^/]+)_widget.rb$}, 1]
    end
  end

  def self.get name
    "::#{name.to_s.camelize}Widget".constantize
  end

  def self.render name, *arguments, &block
    get(name).render(*arguments, &block)
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
