Dir.glob(File.join(File.dirname(__FILE__), 'resources', '*.rb')).each {|f| require f }

module Orange::Plugins
  class Cloud < Base
    views_dir       File.join(File.dirname(__FILE__), 'views')
    resource    Orange::CloudResource.new
  end
end

Orange.plugin(Orange::Plugins::Cloud.new)

