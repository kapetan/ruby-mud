module Mud

  class InstalledModule < Mud::Module
    attr_reader :path, :modified

    def initialize(path, context)
      super(path, Mud.render(:file => path), context)
      @content = nil

      @path = path
      @modified = File.mtime(path)
    end

    def content
      Mud.render :file => @path
    end
  end

end