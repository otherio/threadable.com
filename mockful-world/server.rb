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

get '/stories/new' do
  haml :"stories/new"
end

get '/tasks/layup-body-carbon' do
  haml :"tasks/carbon"
end

get '/tasks/layup-body-carbon2' do
  haml :"tasks/carbon2"
end

get '/tasks/layup-body-carbon3' do
  haml :"tasks/carbon3"
end

get '/tasks/layup-body-carbon4' do
  haml :"tasks/carbon4"
end

# get '/flow/1' do
#   haml :"flow/1"
# end


helpers do
  def message_list
    return [
      ['layup body carbon', 3, 6, '1/5/13', 'me, Be .. <b>Bob</b>', 0, 1],
      ['install mirrors', 1, 1, '1/5/13', '<b>Yan</b>', 0, 1],
      ['trim body panels', 0, 2, '1/4/13', 'Tom, me', 0, 1],
      ['make wooden form for carbon layup', 2, 3, '1/4/13', 'me, Yan, <b>Tom</b>', 1, 1],
      ['mount body on frame', 0, 5, '1/4/13', 'Yan, me, Yan', 0, 1],
      ['install body clips', 0, 2, '1/2/13', 'Tom, Yan', 0, 1],
      ['How are we going to build the body?', 0, 26, '1/2/13', 'Tom, Be .. Tom', 0, 0],
      ['get mirrors', 0, 4, '1/1/13', 'Yan, Tom, me', 0, 1],
      ['get epoxy', 0, 2, '12/28/12', 'me, Yan, Tom', 1, 1],
      ['get release agent', 0, 4, '12/27/12', 'me, Yan, Tom', 1, 1],
      ['get carbon and fiberglass', 0, 2, '12/26/12', 'me, Yan, Tom', 1, 1],
    ]
  end
end
