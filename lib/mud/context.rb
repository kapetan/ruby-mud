module Mud

  class ResolveError < StandardError
    attr_reader :name

    def initialize(name_or_dependency)
      @name = name_or_dependency.is_a?(Mud::Dependency) ? name_or_dependency.name : name_or_dependency
      super("No module named '#{@name}' in context")
    end
  end

  class Context
    MODULE_DIRECTORIES  = ['js_modules', 'shared_modules']
    MODULE_GLOBAL = File.join(Mud::Utils::HOME_DIRECTORY, '.mud', 'js_modules')

    attr_reader :available_modules, :dir

    def initialize(dir = '.')
      @dir = File.absolute_path(dir)
      @available_modules = {}
      reload
    end

    def reload
      dirs = dirs(@dir)
      removed = @available_modules.dup

      dirs.each do |dir|
        Dir.glob(File.join(dir, '*.js')) do |mod_path|
          name = Mud::Module.parse_name(mod_path)
          mod = @available_modules[name]
          removed.delete(name)

          unless mod and mod.modified == File.mtime(mod_path) and mod.path == mod_path
            @available_modules[name] = Mud::InstalledModule.new(mod_path, self)
          end
        end
      end

      @available_modules.delete_if { |key, _| removed.key?(key) }
    end

    def install(name, opts = {})
      return if @available_modules[name]# or raise exception

      src = nil # download module src from mudhub and write to disk in module global
      path = nil

      @available_modules[name] = Mud::InstalledModule.new(path, self) # check dependencies and download if not present
    end

    def uninstall(module_or_name)
    end

    def module(name)
      @available_modules[name]
    end

    def module!(name)
      @available_modules[name] || (raise Mud::ResolveError.new(name))
    end

    def resolve_document(path)
      resolve analyze_document(path).first
    end

    def inline_document(path, opts = {})
      modules, type = analyze_document(path)

      result = inline(modules, opts)

      if type == :js
        main = modules.first
        result << main.content
      else
        result = Mud::HtmlResult.new(path, result)
      end

      result
    end

    def resolve(module_or_list)
      modules = module_or_list.is_a?(Mud::Module) ? [module_or_list] : module_or_list

      resolved = []

      resolver = proc do |modules|
        modules.each do |mod|
          next if resolved.include?(mod)
          resolved.unshift(mod) if mod.is_a?(Mud::InstalledModule)

          dep = mod.unresolvable_dependencies.first
          raise Mud::ResolveError.new(dep) if dep

          dependencies = mod.dependencies.map(&:resolve).delete_if { |m| resolved.include?(m) }
          resolver.call(dependencies) unless dependencies.empty?
        end
      end
      resolver.call(modules)

      resolved
    end

    def inline(module_or_list, opts = {})
      resolved = resolve(module_or_list)
      opts = { :global => false, :compile => nil }.update(opts)

      Mud::JsResult.new(resolved, opts[:global], opts[:compile])
    end

    private

    def analyze_document(path)
      content = Mud.render path
      type = content.match(/^\s*</) ? :html : :js

      modules = if type == :html
        analyze_html(path, content)
      else
        [Mud::Module.new(path, content, self)]
      end

      return modules, type
    end

    def analyze_html(path, html)
      inner_modules = []
      doc = Hpricot(html)

      doc.search('//script').each do |script_tag|
        src = script_tag.attributes['src']

        if src and not src.empty? and not src.match(/^\w+:\/\//)
          begin
            content = Mud.render Mud.join(path, src)
            inner_modules << Mud::Module.new(src, content, self)
          rescue Errno::ENOENT, Net::HTTPError
            # Does not exist. Ignore.
          end
        end

        content = script_tag.inner_html
        if content and not content.empty?
          inner_modules << Mud::Module.new("#{File.basename(path)}-embedded-script-#{inner_modules.length}", content, self)
        end
      end

      inner_modules
    end

    def dirs(start)
      dirs = [MODULE_GLOBAL]

      current = File.absolute_path(start)
      while true
        dirs += MODULE_DIRECTORIES.each { |dir| File.join(current, dir) }
        break if current == Mud.root_directory
        current = File.expand_path('..', current)
      end

      dirs.keep_if { |dir| File.exists?(dir) }
    end

    def in(*paths)
      File.join(@dir, *paths)
    end
  end

end