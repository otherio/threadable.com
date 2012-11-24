module Multify::Servers

  def self.start!
    @api = Api.new
    @www = Www.new

    debugger;1

    @api.start!
    @www.start!
  end

end


require 'multify/servers/rails_app'
require 'multify/servers/api'
require 'multify/servers/www'
