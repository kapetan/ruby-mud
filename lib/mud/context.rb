module Mud

  class Context
    include Mud::Exceptions

    MODULE_DIRECTORIES  = ['js_modules', 'shared_modules']
    MODULE_GLOBAL = Mud.home_directory('.mud', 'js_modules')

    IGNORE_SRC = [/^$/, /^\w+:\/\//, /.*\/dev$/]

    attr_reader :available_modules, :dir, :api

    def initialize(dir = '.')
      @dir = File.absolute_path(dir)
      @api = Mud::Api.new
      @available_modules = {}

      setup
      reload
    end

    def setup
      if not File.exists?(MODULE_GLOBAL)
        FileUtils.mkpath(MODULE_GLOBAL)
        File.hide(MODULE_GLOBAL)

        Dir.glob(Mud.mud_directory('js_modules', '*.js')) do |path|
          mod = File.join(MODULE_GLOBAL, File.basename(path))
          FileUtils.cp(path, mod)
        end
      end
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
      name = Mud::Module.parse_name(name)
      opts = { :force => false, :fetch_dependencies => true }.update(opts)

      install_error(name, "Module ${name} already installed") if @available_modules[name] and not opts[:force]

      download = proc do |name|
        begin
          catch :halt do
            yield name if block_given?

            path, dependencies = download_module(name)
            @available_modules[name] = Mud::InstalledModule.new(path, self)

            throw :halt unless opts[:fetch_dependencies]

            dependencies.each do |dep|
              if not dep.resolvable?
                download.call(dep.name)
              end
            end
          end
        rescue Net::HTTPError, Timeout::Error
          # Reraise error
          Mud::InstallError.cause!(name)
        end
      end

      download.call(name)
    end

    def uninstall(installed_module)
      begin
        catch :halt do
          if block_given?
            dependents = @available_modules.values.find_all { |mod| mod.depends_on?(installed_module) }
            yield dependents unless dependents.empty?
          end

          File.unlink(installed_module.path)
          @available_modules.delete(installed_module.name)
        end
      rescue Errno::ENOENT, Errno::EACCES
        Mud::UninstallError.cause!(installed_module)
      end
    end

    def module(name)
      name = Mud::Module.parse_name(name)
      @available_modules[name]
    end

    def module!(name)
      @available_modules[name] || resolve_error(name)
    end

    def resolve_document(path, content = nil)
      resolve analyze_document(path, content).first
    end

    def inline_document(path, content = nil, opts = nil)
      unless opts
        if content.is_a?(Hash)
          opts = content
          content = nil
        else
          opts = {}
        end
      end

      modules, type, content = analyze_document(path, content)

      result = inline(modules, opts)

      if type == :js
        main = modules.first
        result << main.content
      else
        result = Mud::HtmlResult.new(content, result)
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
          resolve_error(dep) if dep

          dependencies = mod.dependencies.map(&:resolve).delete_if { |m| resolved.include?(m) }
          resolver.call(dependencies) unless dependencies.empty?
        end
      end
      resolver.call(modules)

      resolved
    end

    def inline(module_or_list, opts = {})
      resolved = resolve(module_or_list)
      Mud::JsResult.new(resolved, opts)
    end

    private

    def download_module(name)
      name = "#{name}.js" if not name.end_with?('.js')
      response = @api.get(name)

      path = File.join(MODULE_GLOBAL, name)
      File.open(path, 'w') { |f| f.write(response.body) }

      deps = response['x-dependencies']
      return path, (deps ? deps.split(',') : []).map { |name| Mud::Dependency.new(name, self) }
    end

    def ignore_src?(src)
      IGNORE_SRC.any? { |r| r =~ src }
    end

    def analyze_document(path, content)
      content = Mud.render(path) unless content
      type = content.match(/^\s*</) ? :html : :js

      modules = if type == :html
        analyze_html(path, content)
      else
        [Mud::Module.new(path, content, self)]
      end

      return modules, type, content
    end

    def analyze_html(path, html)
      inner_modules = []
      doc = Hpricot(html)

      doc.search('//script').each do |script_tag|
        src = script_tag.attributes['src']

        if src and not ignore_src?(src)
          begin
            content = Mud.render src, :basepath => path
            inner_modules << Mud::Module.new(src, content, self)
          rescue Errno::ENOENT, Net::HTTPError, Timeout::Error
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
        dirs += MODULE_DIRECTORIES.map { |dir| File.join(current, dir) }
        break if current == Mud.root_directory
        current = File.expand_path('..', current)
      end

      dirs.keep_if { |dir| File.exists?(dir) }
    end
  end

end