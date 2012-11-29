require 'rubygems'
require 'bundler'
Bundler.require

class Server < Sinatra::Base

  set :views,         './views'
  set :public_folder, './public'
  set :css_folder,    './stylesheets'
  set :js_folder,     './javascripts'
  set :css_load_paths, ->{
    Compass.configuration.sass_load_paths + [settings.css_folder]
  }

  get '/' do
    haml :application
  end

  get '/application.js' do
    js :application
  end

  get '/application.css' do
    sass :application
  end

  helpers do

    def sass name
      content_type 'text/css'
      sass = File.read(File.join(settings.css_folder, "#{name}.sass"))
      Sass::Engine.new(sass, :load_paths => settings.css_load_paths).to_css
    end

    def js name
      content_type 'application/javascript'
      sprockets_environment.find_asset("#{name}.js").to_s
    end

    def sprockets_environment
      @sprockets_environment ||= begin
        environment = Sprockets::Environment.new(Dir.pwd)
        environment.append_path settings.js_folder
        environment
      end
    end

  end

end

