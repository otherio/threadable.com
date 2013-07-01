require 'resque/server'
Resque::Server.use Rack::Auth::Basic do |username, password|
  username == 'covered' && password == ENV['COVERED_PASSWORD'].to_s
end
