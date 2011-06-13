module Mud

  class Api
    HOST = 'mudhub.org'
    PORT = 80

    SERVER_TIMEOUT = 5 #seconds

    def get(module_name, &block)
      perform_request('GET', "/r/#{js(module_name)}")
    end

    def publish(mod, name = nil)
      perform_request('PUT', "/r/#{js(name || mod.name)}", mod.content)
    end

    private

    def js(name)
      name.end_with?('.js') ? name : "#{name}.js"
    end

    def perform_request(method, path, body = nil, query = nil, headers = nil)
      if query
        query = query.map { |name, value| "#{URI.escape(name)}=#{URI.escape(value)}" }.join('&')
        path = "#{path}?#{query}"
      end

      Net::HTTP.start(HOST, PORT) do |http|
        http.read_timeout = SERVER_TIMEOUT

        response = http.send_request(method, path, body, headers)
        response.error! unless response.code.to_i == 200

        response
      end
    end
  end

end