module Mud

  File.class_eval do
    def self.hide(file_name, force_rename = false)
      os = RbConfig::CONFIG['host_os']

      if os =~ /mswin|windows|cygwin/i
        raise IOError.new("Could not hide file '#{file_name}' using attrib +h") unless system("attrib +h '#{file_name}'")
        file_name
      else
        # Assume unix-like

        parent, base = dirname(file_name), basename(file_name)

        if base.start_with?('.')
          file_name
        else
          if os =~ /darwin/i and not force_rename
            # OS X
            raise IOError.new("Could not hide file '#{file_name}' using SetFile -a -V") unless system("SetFile -a V '#{file_name}'")
            return file_name
          end

          hidden = join(parent, ".#{base}")
          raise IOError.new("Can't hide '#{file_name}' by renaming to '#{hidden} (already exists)") if exists?(hidden)
          rename(file_name, hidden)
          hidden
        end
      end
    end
  end

  module Utils
    JS_DIRECTORY = File.expand_path(File.join File.dirname(__FILE__), '..', '..', 'js')

    ROOT_DIRECTORY = File.absolute_path('/')
    HOME_DIRECTORY = Dir.home

    [:js, :root, :home].each do |name|
      name = "#{name}_directory"
      module_eval %{
        def #{name}(*paths)
          File.join(#{name.upcase}, *paths)
        end
      }
    end

    def compile(src, type = 'simple', out = nil)
      raise ArgumentError.new("Type must be either 'simple' or 'advanced', was '#{type}'") unless ['simple', 'advanced'].include?(type.to_s)
      level = "#{type.upcase}_OPTIMIZATIONS"

      response = Net::HTTP.post_form(URI.parse('http://closure-compiler.appspot.com/compile'),
        :output_info => 'compiled_code',
        :compilation_level => level,
        :warning_level => 'default',
        :js_code => src)

      if out
        File.open(out) { |f| f.write(response.body) }
      end

      response.body
    end

    def render(location, opts = {})
      if location.is_a?(Hash)
        opts = location
      else
        opts = guess(location).update(opts)
      end
      
      type, path = opts.first

      content = case type
        when :erb, :file then
          basepath = opts[:basepath] || path
          basepath = basepath.gsub(/^file:\/\//, '')

          path = opts[:basepath] ? File.join(basepath, path) : basepath

          File.open(path) { |f| f.read }
        when :http then
          basepath = opts[:basepath] || path
          basepath = "http://#{basepath}" unless basepath.start_with?('http://')

          path = opts[:basepath] ? URI.join(basepath, path) : basepath

          response = Net::HTTP.get_response(URI.parse(path))
          response.error! unless (200..299).include?(response.code.to_i)
          response.body
        else
          raise ArgumentError.new("Unknown type '#{type}'")
      end

      if type == :erb
        locals = opts[:locals] || {}
        content = ERB.new(content).result(LocalsBinding.new(locals).binding)
      end

      content
    end
    alias :cat :render

    private

    class LocalsBinding < BasicObject
      def initialize(locals, &block)
        @_locals = locals

        locals.each_pair do |name, value|
          instance_eval %{
            def #{name}
              _get(:#{name})
            end
          }
        end

        instance_eval(&block) if block
      end

      def js_directory(*paths)
        ::Mud.js_directory(*paths)
      end

      def render(opts)
        ::Mud.render(opts.update :basepath => js_directory)
      end

      def binding
        ::Proc.new {}.binding
      end

      private

      def _get(name)
        @_locals[name.to_sym] || @_locals[name.to_s]
      end
    end

    def guess(path)
      protocol = (path.match(/^(\w+):\/\//) || [])[1] || 'file'
      { protocol.to_sym => path }
    end
  end

end