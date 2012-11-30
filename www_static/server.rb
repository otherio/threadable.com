require 'rubygems'
require 'bundler'
Bundler.require
require 'pathname'

class Server < Sinatra::Base

  ROOT = Pathname.new File.expand_path('../',__FILE__)

  set :root,          ROOT
  set :static,        true

end

