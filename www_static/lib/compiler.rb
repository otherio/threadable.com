require 'pathname'
require 'fileutils'

class Compiler
  ROOT = Pathname.new File.expand_path('../../',__FILE__)
  PUBLIC = ROOT + 'public'

  def initialize
    @javascripts = ROOT + 'javascripts'
    @stylesheets = ROOT + 'stylesheets'
    destroy_public!
    compile_html!
    compile_stylesheet!
    compile_javascript!
    copy_images!

  end

  def destroy_public!
    puts "destroying #{PUBLIC}"
    FileUtils.rm_rf(PUBLIC)
    FileUtils.mkdir(PUBLIC)
  end

  def compile_html!
    puts "compiling html"
    haml = ROOT.join('views/application.haml').read
    html = Haml::Engine.new(haml).to_html
    PUBLIC.join('index.html').open('w'){|f| f.write(html) }
  end

  def compile_stylesheet!
    puts "compiling stylesheet"
    load_paths = Compass.configuration.sass_load_paths + [@stylesheets]
    sass = File.read(@stylesheets + "application.sass")
    css = Sass::Engine.new(sass, :load_paths => load_paths).to_css
    PUBLIC.join('application.css').open('w'){|f| f.write(css) }
  end

  def compile_javascript!
    puts "compiling javascript"
    javascript = sprockets_environment.find_asset("application.js").to_s
    PUBLIC.join('application.js').open('w'){|f| f.write(javascript) }
  end

  def sprockets_environment
    @sprockets_environment ||= begin
      environment = Sprockets::Environment.new(Dir.pwd)
      environment.append_path(@javascripts)
      environment
    end
  end

  def copy_images!
    puts "copying images"
    FileUtils.copy_entry(ROOT+'images', PUBLIC+'images')
  end

end
