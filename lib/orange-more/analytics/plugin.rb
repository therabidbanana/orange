Dir.glob(File.join(File.dirname(__FILE__), 'resources', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'middleware', '*.rb')).each {|f| require f }

module Orange::Plugins
  class Analytics < Base
    resource    Orange::AnalyticsResource.new
    prerouter   Orange::Middleware::Analytics
  end
end

Orange.plugin(Orange::Plugins::Analytics.new)