require 'mud'

namespace :mud do
  js_dir = File.join(Rails.public_path, 'javascripts')
  mud_dir = File.join(js_dir, 'mud')

  relative = proc { |name| Pathname.new(name).relative_path_from(Pathname.new(Dir.pwd)) }

  directory mud_dir

  desc "List dependencies"
  task :dependencies, :dir, :base do |_, args|
    dir = args[:dir] || js_dir
    context = Mud::Context.new(args[:base] || js_dir)

    puts "Checking files for dependencies in #{relative.call dir}"

    Dir.glob(File.join(dir, '*.js')) do |name|
      modules = context.resolve_document(name)
      #deps = modules.empty? ? '' : modules.map { |m| m.name }.join(',')
      puts "\t#{relative.call name}" unless modules.empty?
      modules.each { |m| puts "\t\t#{m.name}" }
    end
  end

  desc "Compiles the dependencies for all .js files in the given directory (defaults to public/javascripts)"
  task :build, [:dir, :base] => mud_dir do |_, args|
    dir = args[:dir] || js_dir

    context = Mud::Context.new(args[:base] || js_dir)
    all = Set.new

    puts "Compiling dependencies"

    write = proc do |name, js|
      js = js.to_s
      File.open(File.join(mud_dir, File.basename(name)), 'w') { |f| f.write(js) }
    end

    Dir.glob(File.join(dir, '*.js')) do |name|
      modules = context.resolve_document(name)

      puts "\t#{relative.call(name)} (#{modules.length} dependencies)"

      unless modules.empty?
        all += modules

        result = Mud::JsResult.new(modules, :compile => :simple)
        write.call(name, result)
      end
    end
    
    write.call('all.js', Mud::JsResult.new(all, :compile => :simple)) unless all.empty?
  end
end