module Mud

  class Dependency
    def self.analyze(src, context)
      dependencies = Set.new

      # Find all required files on the form require('name') og require('name', 'sub_name', ...)
      src.scan(/require\(((?:'[^']+'(?:,\s)?)+)\)/).each do |req|
        req.first.scan(/'([^']+)'/).each { |name| dependencies << new(name.first, context) }
      end

      dependencies.to_a
    end

    attr_reader :name, :context

    def initialize(name, context)
      @name = name
      @context = context
    end

    def to_s
      "Mud::Dependency #{@name}"
    end

    def ==(other)
      other.is_a?(self.class) and other.name == @name
    end

    def resolvable?
      !!resolve
    end

    # Resolves to the corresponding module if present in this context.
    def resolve
      @context.module(@name)
    end
  end

end