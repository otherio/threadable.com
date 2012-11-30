require 'pathname'
require 'fileutils'

class Compiler
  ROOT        = Pathname.new File.expand_path('../../',__FILE__)
  PUBLIC      = ROOT + 'public'
  HTML        = ROOT + 'views/application.haml'
  STYLESHEETS = ROOT + 'stylesheets'
  JAVASCRIPTS = ROOT + 'javascripts'

  def self.compile_all!
    compile_html!
    compile_stylesheet!
    compile_javascript!
    copy_images!
  end

  def self.compile_html!
    puts "compiling html"
    haml = HTML.read
    html = Haml::Engine.new(haml).to_html
    PUBLIC.join('index.html').open('w'){|f| f.write(html) }
  end

  def self.compile_stylesheet!
    puts "compiling stylesheet"
    load_paths = Compass.configuration.sass_load_paths + [STYLESHEETS]
    sass = File.read(STYLESHEETS + "application.sass")
    css = Sass::Engine.new(sass, :load_paths => load_paths).to_css
    PUBLIC.join('application.css').open('w'){|f| f.write(css) }
  end

  def self.compile_javascript!
    puts "compiling javascript"
    javascript = sprockets_environment.find_asset("application.js").to_s
    PUBLIC.join('application.js').open('w'){|f| f.write(javascript) }
  end

  def self.sprockets_environment
    @sprockets_environment ||= begin
      environment = Sprockets::Environment.new(Dir.pwd)
      environment.append_path(JAVASCRIPTS)
      environment
    end
  end

  def self.copy_images!
    puts "copying images"
    FileUtils.rm_rf(PUBLIC+'images')
    FileUtils.copy_entry(ROOT+'images', PUBLIC+'images')
  end

end
