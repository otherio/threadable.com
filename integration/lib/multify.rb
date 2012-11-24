require 'pathname'

module Multify

  def self.root
    @root ||= Pathname.new(File.expand_path('../../../',__FILE__))
  end

end


require 'multify/servers'
