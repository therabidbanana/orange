Dir.glob(File.join(File.dirname(__FILE__), 'cartons', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'resources', '*.rb')).each {|f| require f }

module Orange::Plugins
  class Assets < Base
    views_dir   File.join(File.dirname(__FILE__), 'views')
    
    resource    :assets, Orange::AssetResource.new
  end
end

Orange.plugin(Orange::Plugins::Assets.new)

