module Mud
  module Integrations

    class Rack
      def initialize(app, base = '.')
        @app = app
        @context = Mud::Context.new(base)
      end

      def call(env)
        status, headers, response = @app.call(env)
        request = ::Rack::Request.new(env)
        
        body = []
        response.each { |s| body << s }

        unless body.empty?
          body = @context.inline_document(request.url, body.join('')).to_s
        end
        
        headers['Content-Length'] = body.bytesize.to_s

        [status, headers, [body]]
      end
    end

  end
end