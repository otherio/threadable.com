require 'sinatra'
require 'compass'

configure do
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = 'views'
  end

  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options
  set :scss, Compass.sass_engine_options
end

get '/stylesheet.css' do
  content_type 'text/css'
  sass :stylesheet
end

get '/' do
  haml :index
end

get '/clickconvo' do
  haml :clickconvo
end

get '/public' do
  haml :public
end


get '/styleguide' do
  haml :styleguide
end


