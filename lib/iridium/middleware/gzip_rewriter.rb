require 'rack/request'

module Iridium
  module Middleware
    class GzipRewriter
      def initialize(app, iridium)
        @app, @iridium = app, iridium
      end

      def call(env)
        if wants_gzipped?(env) && gzipped?(env)
          env['PATH_INFO'] += ".gz"
          status, headers, body = @app.call env

          headers['Content-Encoding'] = 'gzip'

          [status, headers, body]
        else
          @app.call env
        end
      end

      private
      def asset_path(env)
        @iridium.site_path.join(env['PATH_INFO'].gsub(/^\//, ''))
      end

      def gzipped?(env)
        File.exists? "#{asset_path(env)}.gz"
      end

      def wants_gzipped?(env)
        request = ::Rack::Request.new env
        request.accept_encoding.find { |e| e[0] == 'gzip' }
      end
    end
  end
end
