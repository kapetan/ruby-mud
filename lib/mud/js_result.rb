module Mud

  class JsResult
    def initialize(modules, opts = {})
      opts = { :global => false, :compile => nil }.update(opts)

      @modules = modules
      @global = opts[:global]
      @compile = opts[:compile]

      @appends = []
    end

    def empty?
      @modules.empty?
    end

    def to_s
      if empty?
        ''
      else
        result = Mud.render :erb => (@global ? 'global.js.erb' : 'inline_modules.js.erb'),
                        :locals => { :modules => @modules, :appends => @appends }, :basepath => Mud.mud_directory('js')
        @compile ? Mud.compile(result, @compile) : result
      end
    end

    def <<(src)
      @appends << src
    end
  end
  
end