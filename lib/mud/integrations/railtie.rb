require 'mud'
require 'rails'

require 'mud/integrations/rack'

module Mud
  module Integrations

    class Railtie < Rails::Railtie
      initializer 'mud.rack_middleware' do |app|
        if ['test', 'development'].include?(Rails.env)
          app.config.middleware.use Mud::Integrations::Rack, File.join(Rails.public_path, 'javascripts')
        end
      end
    end

  end
end