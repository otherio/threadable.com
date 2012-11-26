require 'multify/version'
require 'rest-client'
require 'json'
require 'virtus'
require 'base64'

module Multify

  class << self

    attr_reader :host
    attr_accessor :authentication_token

    def host= host
      @host = URI.parse(host)
    end

    def authenticate email, password
      url = host+'/users/sign_in'
      authorization = "Basic #{::Base64.strict_encode64("#{email}:#{password}")}"
      response = RestClient.post(url.to_s, {}, {
        :AUTHORIZATION => authorization,
        :accept => :json,
      })
      response = JSON.parse(response)
      self.authentication_token = response["authentication_token"]
      return [
        self.authentication_token,
        Multify::User.new(response["user"]),
      ]
    end

    def authenticated?
      !authentication_token.nil?
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
