module Orange::Middleware

  # The Orange::Middleware::Static middleware intercepts requests for static files
  # (javascript files, images, stylesheets, etc) based on the url prefixes
  # passed in the options, and serves them using a Rack::File object. 
  #
  # This differs from Rack::Static in that it can serve from multiple roots
  # to accommodate both Orange static files and site specific ones.
  # 
  # Each lib is responsible for responding to static_url and static_dir
  # 
  # Examples:
  #           use Orange::Middleware::Static  :libs => [Orange::Core, AwesomeMod]
  #           use Orange::Middleware::Static  :libs => [Orange::Core, AwesomeMod],
  #                                           :urls => {"/favicon.ico" => Dir.pwd + '/assets'}
  #
  #         => Example 1 would load a file root for Orange::Core and Awesome Mod
  #             Orange::Core static_url is _orange_, and dir is the
  #             orange lib/assets folder
  #         => Example 2 would also redirect favicon.ico to the assets dir
  #
  # 
  # Note that as a general rule, Orange will assume everything static to be in an
  # /assets/ subfolder, therefore, '/assets' will be prepended to the url given
  # by static_url
  # Also note, that since this is the case - setting up a match for general '/assets'
  # could yield unpredictable results
  #
  # a static_url corresponds to the :module => in the add_css and add_js helpers
  class Static

    def initialize(app, options={})
      @app = app
      @libs = options[:libs] || [Orange::Core]
      
      @urls = options[:urls] || {"/favicon.ico" => nil, "/assets/public" => nil}
      @libs.each do |lib| 
        @urls.merge!(File.join('', 'assets', lib.static_url) => lib.static_dir)
      end
      @file_servers = {}
      @urls.each do |k, v|
        v = File.join(Dir.pwd, 'assets') unless v
        @file_servers.merge!(k => Rack::File.new(v))
      end
    end

    def call(env)
      path = env["PATH_INFO"]
      can_serve = @file_servers.select { |url, server| path.index(url) == 0 }.first
      # Extract url 
      url = can_serve ? can_serve.first : false
      
      if can_serve
        env["PATH_INFO"] = path.split(url, 2).last
        can_serve.last.call(env)
      else
        @app.call(env)
      end
    end

  end
end