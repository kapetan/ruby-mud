module Mud

  class JsResult
    def initialize(modules, global = false, compile = 'simple')
      @modules = modules
      @global = global
      @compile = compile

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