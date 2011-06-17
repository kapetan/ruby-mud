require 'mud'

module Mud
  module Integrations

    module Rails
      def self.included(base)
        base.class_eval do
          base.send(:after_filter, Filter.new)
        end
      end

      class Filter
        def initialize
          @context = Mud::Context.new(File.join(::Rails.public_path, 'javascripts'))
        end

        def filter(controller)
          @context.reload

          response = controller.response
          url = controller.request.url

          body = @context.inline_document(url, response.body)
          response.body = body.to_s
        end
      end
    end

  end
end