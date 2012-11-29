require 'rubygems'
require 'bundler'
Bundler.require
require 'pathname'

class Server < Sinatra::Base

  ROOT = Pathname.new File.expand_path('../',__FILE__)

  set :views,         ROOT + 'views'
  set :public_folder, ROOT + 'public'
  set :stylesheets,   ROOT + 'stylesheets'
  set :javascripts,   ROOT + 'javascripts'
  # set :templates,     ROOT + 'javascripts'

  get '/' do
    haml :application, layout: false
  end

  helpers do

    def stylesheet
      load_paths = Compass.configuration.sass_load_paths + [settings.stylesheets]
      sass = File.read(settings.stylesheets + "application.sass")
      Sass::Engine.new(sass, :load_paths => load_paths).to_css
    end

    def javascript
      javascript = sprockets_environment.find_asset("application.js").to_s

      templates = []
      settings.views.find do |path|
        next unless path.file?
        extname = path.extname
        name = path.relative_path_from(settings.views).to_s[/(.*)#{Regexp.escape(extname)}$/,1]
        next if name == 'application'
        value = path.read
        value = case extname
        when '.haml'
          Haml::Engine.new(value).to_html
        else
          value
        end
        templates << "new Multify.View.Template(#{name.to_json}, #{value.to_json});"
      end

      javascript << templates.join("\n")

      javascript
    end



    # def sass name
    #   content_type 'text/css'
    #   sass = File.read(File.join(settings.css_folder, "#{name}.sass"))
    #   Sass::Engine.new(sass, :load_paths => settings.css_load_paths).to_css
    # end

    # def js name
    #   content_type 'application/javascript'
    #   sprockets_environment.find_asset("#{name}.js").to_s
    # end

    def sprockets_environment
      @sprockets_environment ||= begin
        environment = Sprockets::Environment.new(Dir.pwd)
        environment.append_path settings.javascripts
        environment
      end
    end

  end

end

