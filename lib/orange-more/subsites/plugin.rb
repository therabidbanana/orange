Dir.glob(File.join(File.dirname(__FILE__), 'cartons', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'resources', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'middleware', '*.rb')).each {|f| require f }

module Orange::Plugins
  class Subsites < Base
    views_dir       File.join(File.dirname(__FILE__), 'views')
    
    resource    Orange::SubsiteResource.new
    
    prerouter   Orange::Middleware::SubsiteLoad
    
  end
end

Orange.plugin(Orange::Plugins::Subsites.new)

