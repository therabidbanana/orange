Dir.glob(File.join(File.dirname(__FILE__), 'cartons', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'resources', '*.rb')).each {|f| require f }

module Orange::Plugins
  class Events < Base
    views_dir       File.join(File.dirname(__FILE__), 'views')
    assets_dir      File.join(File.dirname(__FILE__), 'assets')
    resource    Orange::CalendarResource.new
    resource    Orange::EventResource.new
  end
end

Orange.plugin(Orange::Plugins::Events.new)

