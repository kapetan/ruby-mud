module Mud

  class InstalledModule < Mud::Module
    attr_reader :path, :modified

    def initialize(path, context)
      super(path, File.open(path) { |f| f.read }, context)
      @content = nil

      @path = path
      @modified = File.mtime(path)
    end

    def content
      File.open(@path) { |f| f.read }
    end
  end

end