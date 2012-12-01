require 'rubygems'
require 'bundler'
Bundler.require
require 'pathname'

class Server < Sinatra::Base

  ROOT = Pathname.new File.expand_path('../',__FILE__)
  PUBLIC      = ROOT + 'public'
  VIEWS       = ROOT + 'views'
  INDEX_HTML  = VIEWS + 'index.haml'
  STYLESHEETS = ROOT + 'stylesheets'
  JAVASCRIPTS = ROOT + 'javascripts'

  set :views,         VIEWS
  set :public_folder, PUBLIC
  set :stylesheets,   STYLESHEETS
  set :javascripts,   JAVASCRIPTS

  before do
    compile_javascript!
    compile_stylesheet!
  end

  get '*' do
    haml :index, layout: false
  end

  helpers do

    def compile_stylesheet!
      puts "compiling stylesheet"
      load_paths = Compass.configuration.sass_load_paths + [STYLESHEETS]
      sass = File.read(STYLESHEETS + "application.sass")
      css = Sass::Engine.new(sass, :load_paths => load_paths).to_css
      PUBLIC.join('application.css').open('w'){|f| f.write(css) }
    end

    def compile_javascript!
      puts "compiling javascript"
      javascript = sprockets_environment.find_asset("application.js").to_s

      VIEWS.find do |path|
         next unless path.file?
         next if path == INDEX_HTML
         extname = path.extname
         name = path.relative_path_from(VIEWS).to_s[/(.*)#{Regexp.escape(extname)}$/,1]

         next if name[0] == '.'

         value = path.read
         value = case extname
         when '.haml'
           Haml::Engine.new(value).to_html
         else
           value
         end
         javascript << "new Multify.Template(#{name.to_json}, #{value.to_json});"
       end

      PUBLIC.join('application.js').open('w'){|f| f.write(javascript) }
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

