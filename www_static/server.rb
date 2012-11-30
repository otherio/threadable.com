require 'rubygems'
require 'bundler'
Bundler.require
require 'pathname'

class Server < Sinatra::Base

  ROOT = Pathname.new File.expand_path('../',__FILE__)

  set :root,          ROOT
  set :static,        false
  set :public_folder, ROOT + 'public'
  set :views,         ROOT + 'views'
  set :stylesheets,   ROOT + 'stylesheets'
  set :javascripts,   ROOT + 'javascripts'
  # set :templates,     ROOT + 'javascripts'

  get '*' do
    debugger;1
  end

  before do
    compile_html!
    compile_stylesheet!
    compile_javascript!
  end

  # get '/' do
  #   haml :application, layout: false
  # end

  # get '/application.js' do
  #   content_type 'application/javascript'
  #   javascript
  # end

  # get 'application.css' do
  #   content_type 'text/css'
  #   stylesheet
  # end


  helpers do
    def compile_html!
      puts "compiling html"
      html = haml(:application, layout: false)
      ROOT.join('public/index.html').open('w'){|f| f.write(html) }
    end

    def compile_stylesheet!
      puts "compiling stylesheet"
      load_paths = Compass.configuration.sass_load_paths + [settings.stylesheets]
      sass = File.read(settings.stylesheets + "application.sass")
      css = Sass::Engine.new(sass, :load_paths => load_paths).to_css
      ROOT.join('public/application.css').open('w'){|f| f.write(css) }
    end

    def compile_javascript!
      puts "compiling javascript"
      javascript = sprockets_environment.find_asset("application.js").to_s
      ROOT.join('public/application.js').open('w'){|f| f.write(javascript) }
    end

    def sprockets_environment
      @sprockets_environment ||= begin
        environment = Sprockets::Environment.new(Dir.pwd)
        environment.append_path settings.javascripts
        environment
      end
    end

  end

end

