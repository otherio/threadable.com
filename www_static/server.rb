require 'rubygems'
require 'bundler'
Bundler.require
require 'pathname'

class Server < Sinatra::Base

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
    haml STATIC.join('spec/SpecRunner.haml').read, layout: false
  end

  get '*' do
    haml :index, layout: false, :haml_options => {:escape_html => false}
  end

  helpers do

    def specs
      specs = []
      SPEC.find do |path|
        specs << Pathname.new($1).relative_path_from(STATIC).to_s if path.to_s =~ /(.*)\.js$/
      end
      specs
    end

  end

end

