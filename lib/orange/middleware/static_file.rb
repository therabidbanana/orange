require 'rack'
require 'rack/utils'

module Orange::Middleware
  # Rack::File serves files below the +root+ given, according to the
  # path info of the Rack request.
  # Orange::Middleware::StaticFile acts the same as Rack::File, but acts on
  # the orange specific path if available. (So site url would be ignored, etc.)
  #
  # Handlers can detect if bodies are a Rack::File, and use mechanisms
  # like sendfile on the +path+.

  class StaticFile < Rack::File
    def _call(env)
      @path_info = Rack::Utils.unescape(env['orange.env']["route.path"]) || Rack::Utils.unescape(env["PATH_INFO"])
      @root = env['orange.env']['file.root'] || @root
      return forbidden  if @path_info.include? ".."

      @path = F.join(@root, @path_info)

      begin
        if F.file?(@path) && F.readable?(@path)
          serving
        else
          raise Errno::EPERM
        end
      rescue SystemCallError
        not_found
      end
    end
  end
end