require 'orange/middleware/base'
module Orange::Middleware
  class Loader < Base
    def init(*args)
      Dir.glob(File.join(orange.app_dir, 'resources', '*.rb')).each do |f| 
        require f 
        orange.load Orange::Inflector.constantize(Orange::Inflector.camelize(File.basename(f, '.rb'))).new
      end
      
    end
    
    def packet_call(packet)
      pass packet
    end
  end  
end