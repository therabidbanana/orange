require 'orange-core/middleware/base'
module Orange::Middleware
  class Loader < Base
    def init(*args)
      Dir.glob(File.join(orange.app_dir, 'resources', '*.rb')).each do |f| 
        require f 
        orange.load Orange::Inflector.constantize(Orange::Inflector.camelize(File.basename(f, '.rb'))).new
      end
      Dir.glob(File.join(orange.app_dir, 'cartons', '*.rb')).each { |f|  require f }
      Dir.glob(File.join(orange.app_dir, 'middleware', '*.rb')).each { |f|  require f }
    end
  end  
end