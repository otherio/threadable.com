require 'resque/server'
Resque::Server.use Rack::Auth::Basic do |username, password|
  username == 'multify' && password == ENV['MULTIFY_PASSWORD'].to_s
end
