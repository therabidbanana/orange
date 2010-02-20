Dir.glob(File.join(File.dirname(__FILE__), 'resources', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'middleware', '*.rb')).each {|f| require f }

module Orange::Plugins
  class Slices < Base    
    resource    Orange::Radius.new
    resource    Orange::Slices.new
    
    postrouter  Orange::Middleware::RadiusParser
    
  end
end

Orange.plugin(Orange::Plugins::Slices.new)

