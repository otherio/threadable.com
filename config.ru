# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../api/config/environment',  __FILE__)
run MultifyApi::Application
