module Mud

  class Result
    def initialize(modules, global = false, compile = 'simple')
      @modules = modules
      @global = global
      @compile = compile

      reset
    end

    def to_s
      result = Mud.render :erb => (@global ? 'global.js.erb' : 'inline_modules.js.erb'),
                  :locals => { :modules => @modules, :appends => @appends }
      @compile ? Mud.compile(result, @compile) : result
    end

    def append(src)
      @appends << src
    end
    alias :<< :append

    def reset
      @appends = []
    end
  end
  
end