require 'mud'
require 'rails'

require 'mud/integrations/rails_filter'

module Mud
  module Integrations

    class Railtie < ::Rails::Railtie
      rake_tasks do
        load 'mud/integrations/tasks.rb'
      end

      initializer 'mud.rails_filter' do
        ActionController::Base.send(:include, Mud::Integrations::Rails)
      end
    end

  end
end