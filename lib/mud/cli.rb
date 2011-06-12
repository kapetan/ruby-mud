require 'mud/version'

module Mud

  class CLI < Thor
    include Thor::Actions

    def initialize(*)
      super
      @context = Mud::Context.new
      say("(in #{@context.dir})")
    end

    map "ls" => "list"

    desc "resolve PATH", "resolve the given path"
    method_option :compile, :default => nil, :desc => "compile loaded modules"
    def resolve(path)
      modules = @context.resolve_document(path)
      result = Mud::JsResult.new(modules, :compile => options[:compile])
      say(result.to_s)
    end

    desc "inline PATH", "resolve and inline the given path"
    method_option :compile, :default => nil, :desc => "compile loaded modules"
    def inline(path)
      result = @context.inline_document(path, :compile => options[:compile])
      say(result.to_s)
    end

    desc "module A,B,...,C", "load in these modules"
    method_option :compile, :default => nil, :desc => "compile loaded modules"
    #method_option :output, :default => nil, :desc => "output file"
    def modules(modules)
      modules = modules.split(',').map { |mod_name| @context.module!(mod_name) }
      result = @context.inline(modules, :compile => options[:compile])

      if out = options[:output]
        File.open(out, 'w') { |f| f.write(result.to_s) }
      else
        say(result.to_s)
      end
    end

    desc "server", "run a mud server"
    #method_options :fork, :default => false, :desc => "run the server as a daemon (only supported on unix platforms)"
    def server
      Mud::Server.context = @context
      Mud::Server.run!
    end

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

    desc "version", "prints the current version"
    def version
      say(Mud::VERSION)
    end

    desc "install NAME", "fetch and install a module + dependencies"
    def install(name)
      @context.install(name) do |name|
        say("Downloading module '#{name}'")
      end
    end

    desc "uninstall NAME", "uninstall a module"
    def uninstall(name)
      mod = @context.module!(name)

      @context.uninstall(mod) do |dependents|
        say("Modules #{dependents.map { |m| m.name }.join(',')} depend on '#{mod.name}'")
        abort = yes?("Abort?")
        throw :halt if abort
      end
    end
  end

end