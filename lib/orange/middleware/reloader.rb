module Orange::Middleware
  class Reloader
    def initialize(app)
      @app = app
    end
    def call(env)
      @app = @app.class.new(@app.options)
      $stderr.puts "Reloading app class #{@app.class}"
      @app.call(env)
    end
  end
end