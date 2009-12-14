require 'orange/middleware/base'
module Orange::Middleware
  
  class Globals < Base
    def init(*args)
      opts = args.extract_options!.with_defaults(:file => "__ORANGE__/config.yml")
      @file = opts[:file].gsub('__ORANGE__', orange.app_dir)
      @globals = orange[:parser].yaml(@file)
    end
    def packet_call(packet)
      globs = packet['orange.globals'] || {}
      globs.merge! orange.options
      packet['orange.globals'] = globs.merge @globals
      pass packet
    end
    
  end
end