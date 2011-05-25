module Mud

  class Server < Sinatra::Base
    enable :logging, :dump_errors, :inline_templates
    disable :static, :run

    set :port, 10000

    class << self
      def port=(port)
        set :port, port
      end

      def context=(context)
        @@context = context
      end
    end

    helpers do
      def context
        unless defined?(@@context)
          @@context = Mud::Context.new
        else
          @@context.reload
        end

        @@context
      end
      
      def js
        content_type 'application/javascript'
      end

      def process_modules(modules, opts)
        halt 400 if modules.nil? or modules.empty?
        modules = modules.split(',').map { |name| context.module!(name) }
        context.inline(modules, opts).to_s
      end
    end

    get '/dev' do
      ref = params[:ref] || request.referrer

      js
      if ref.nil? or ref == '/'
        host = "#{request.host.split(':').first}:#{settings.port}"
        erb :dev, :locals => { :host => host }
      else
        modules = context.resolve_document(ref)
        context.inline(modules).to_s
      end
    end

    get '/m/:modules' do |modules|
      js
      process_modules(modules, :global => false)
    end

    get '/g/:modules' do |modules|
      js
      process_modules(modules, :global => true)
    end

    get '/p/:var' do |var|
      content_type 'text/html'
      erb :play, :locals => { :var => var }
    end
  end

end

__END__

@@ dev
document.write('<script src="http://<%= host %>/dev?ref=' + window.location + '"></script>');

@@ play
<!DOCTYPE html>
<html>
  <head>
    <title>mud play</title>
    <script src="<%= "/m/#{var}" %>"></script>
  </head>
  <body>
  </body>
</html>