require 'multify/version'
require 'rest-client'
require 'json'
require 'virtus'

module Multify

  class << self

    attr_reader :host

    def host= host
      @host = URI.parse(host)
    end

    def reset!
      Task.all.each(&:delete)
      Project.all.each(&:delete)
      User.all.each(&:delete)
    end

  end

end

require "multify/resource"
require "multify/user"
require "multify/project"
require "multify/task"
