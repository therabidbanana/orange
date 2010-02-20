Dir.glob(File.join(File.dirname(__FILE__), 'cartons', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'resources', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'middleware', '*.rb')).each {|f| require f }

module Orange::Plugins
  class Sitemap < Base
    assets_dir      File.join(File.dirname(__FILE__), 'assets')
    views_dir       File.join(File.dirname(__FILE__), 'views')
    
    resource    :sitemap, Orange::SitemapResource.new
    router  Orange::Middleware::FlexRouter
    
  end
end

Orange.plugin(Orange::Plugins::Sitemap.new)

