Dir.glob(File.join(File.dirname(__FILE__), 'cartons', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'resources', '*.rb')).each {|f| require f }

module Orange::Plugins
  class Donations < Base
    views_dir   File.join(File.dirname(__FILE__), 'views')
    
    resource    Orange::DonationsResource.new
  end
end

Orange.plugin(Orange::Plugins::Donations.new)