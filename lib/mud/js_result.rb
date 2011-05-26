module Mud

  class JsResult
    def initialize(modules, opts = {})
      opts = { :global => false, :compile => nil }.update(opts)

      @modules = modules
      @global = opts[:global]
      @compile = opts[:compile]

      @appends = []
    end

    def to_s
      result = Mud.render :erb => (@global ? 'global.js.erb' : 'inline_modules.js.erb'),
                  :locals => { :modules => @modules, :appends => @appends }, :basepath => Mud.js_directory
      @compile ? Mud.compile(result, @compile) : result
    end

    def <<(src)
      @appends << src
    end
  end
  
end