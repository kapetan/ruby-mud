module Mud

  class CLI < Thor
    include Thor::Actions

    def initialize(*)
      super
      @context = Mud::Context.new
      say("in (#{@context.dir})")
    end

    map "ls" => "list"

    desc "list", "list all installed packages"
    method_option :path, :default => false, :desc => "include module paths"
    def list
      modules = @context.available_modules.values
      if modules.empty?
        say("no modules found")
      else
        modules.each do |m|
          msg = m.name + (options[:path] ? " => #{m.path}" : '')
          say(msg)
        end
      end
    end

    desc "server", "run a mud server"
    #method_options :fork, :default => false, :desc => "run the server as a daemon (only supported on unix platforms)"
    def server
      Mud::Server.context = @context
      #say("mud server started on port #{Mud::Server.port}")
      Mud::Server.run!
    end
  end

end