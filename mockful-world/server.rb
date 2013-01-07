require 'sinatra'

get '/stylesheet.css' do
  content_type 'text/css'
  sass :stylesheet
end

get '/' do
  haml :index
end

