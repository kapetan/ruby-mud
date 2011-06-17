module Mud

  class ModuleError < StandardError
    attr_reader :module_name

    class << self
      def default_message(msg = nil)
        @default_message = msg if msg
        @default_message
      end

      def cause(name, err = $!, msg = nil)
        msg = "#{default_message}. Caused by #{err.message}." unless msg
        module_error = new(name, msg)
        module_error.set_backtrace(err.backtrace)

        module_error
      end

      def cause!(name, err = $!, msg = default_message)
        raise cause(name, err, msg)
      end
    end

    default_message "Module ${name} error"

    def initialize(name, msg = self.class.default_message)
      @module_name = name.respond_to?(:name) ? name.name : name
      super(msg.gsub(/\$\{name\}/, "'#{@module_name}'"))
    end
  end

  class ResolveError < ModuleError
    default_message "No module named ${name} in context"
  end

  class InstallError < ModuleError
    default_message "Error occurred while installing module ${name}"
  end

  class UninstallError < ModuleError
    default_message "Error occurred while trying to uninstall module ${name}"
  end

  class UpdateError < ModuleError
    default_message "Error occurred while updating module ${name}"
  end

  module Exceptions
    [:module, :resolve, :install, :update].each do |name|
      method = "#{name}_error"
      err = "Mud::#{name.capitalize}Error"

      module_eval %{
        def #{method}(name, msg = #{err}.default_message)
          err = #{err}.new(name, msg)
          err.set_backtrace(caller)
          raise err
        end
      }
    end
  end

end