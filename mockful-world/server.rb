require 'sinatra'

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


