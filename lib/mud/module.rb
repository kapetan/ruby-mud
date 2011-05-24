module Mud

  class Module
    attr_reader :name, :content, :context, :dependencies

    def self.parse_name(path_or_name)
      File.basename(path_or_name).split(/\.js$/i).first
    end

    def initialize(name, content, context)
      @name = self.class.parse_name(name)
      @content = content
      @context = context

      @dependencies = Mud::Dependency.analyze(content, context)
    end

    def to_s
      "#{self.class} #{@path}"
    end

    def ==(other)
      other.is_a?(self.class) and other.name == @name
    end

    def unresolvable_dependencies
      @dependencies.select { |d| not d.resolvable? }
    end

    def resolvable?
      @dependencies.all?(&:resolvable?)
    end

    def depends_on?(module_or_dependency)
      !!@dependencies.find { |d| d.name == module_or_dependency.name }
    end
  end

end