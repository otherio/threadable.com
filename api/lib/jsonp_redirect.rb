# middleware to fix jsonp redirects
module Rack
  class JSONPRedirect
    METHOD_OVERRIDE_PARAM_KEY = "_method".freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      request = Rack::Request.new(env)

      params = {}

      if headers['Location']
        location = headers['Location']

        # check for the method override
        # 307 is "use the same request method for this redirect"
        if env['rack.methodoverride.original_method'] && status == 307
          params[METHOD_OVERRIDE_PARAM_KEY] = env["REQUEST_METHOD"].to_s.downcase
        end

        # check for the callback
        if request.params.include?('callback')
          params['callback'] = request.params['callback']
        end

        if location =~ /\?/
          location += '&'
        else
          location += '?'
        end

        location += params.to_query
        headers['Location'] = location
      end

      response = Rack::Response.new body, status, headers
      response.finish
    end
  end
end
