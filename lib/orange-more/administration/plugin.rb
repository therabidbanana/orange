Dir.glob(File.join(File.dirname(__FILE__), 'cartons', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'resources', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'middleware', '*.rb')).each {|f| require f }

module Orange::Plugins
  class Administration < Base
    assets_dir      File.join(File.dirname(__FILE__), 'assets')
    views_dir       File.join(File.dirname(__FILE__), 'views')
    templates_dir   File.join(File.dirname(__FILE__), 'templates')
    
    resource    Orange::AdminResource.new, :admin
    resource    Orange::UserResource.new
    resource    Orange::SiteResource.new
    
    prerouter   Orange::Middleware::AccessControl
    prerouter  Orange::Middleware::SiteLoad
    
  end
end

Orange.plugin(Orange::Plugins::Administration.new)

