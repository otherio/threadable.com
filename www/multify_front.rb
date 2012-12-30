require 'rubygems'
require 'bundler'
Bundler.require
require 'pathname'

class MultifyFront < Sinatra::Base

  ROOT = Pathname.new File.expand_path('../',__FILE__)
  STATIC      = ROOT + 'static'
  VIEWS       = ROOT + 'views'
  INDEX_HTML  = VIEWS + 'index.haml'
  STYLESHEETS = ROOT + 'stylesheets'
  JAVASCRIPTS = ROOT + 'javascripts'
  SPEC        = STATIC + 'spec'

  set :views,         VIEWS
  set :public_folder, STATIC
  set :stylesheets,   STYLESHEETS
  set :javascripts,   JAVASCRIPTS

  get "/spec" do
    haml STATIC.join('spec/SpecRunner.haml').read, layout: false, :haml_options => {:escape_html => false}
  end

  get "/templates/*" do |path|
    path.sub!(/\.html/,'.haml')
    haml VIEWS.join(path).read, layout: false, :haml_options => {:escape_html => false}
  end

  get '*' do
    compile_stylesheet!
    haml :index, layout: false, :haml_options => {:escape_html => false}
  end

  helpers do

    def compile_stylesheet!
      puts "compiling stylesheet"
      load_paths = Compass.configuration.sass_load_paths + [STYLESHEETS]
      sass = File.read(STYLESHEETS + "application.sass")
      css = Sass::Engine.new(sass, :load_paths => load_paths).to_css
      STATIC.join('application.css').open('w'){|f| f.write(css) }
    end


    def specs
      specs = []
      SPEC.find do |path|
        specs << Pathname.new($1).relative_path_from(STATIC).to_s if path.to_s =~ /(.*)\.js$/
      end
      specs
    end

  end

end
