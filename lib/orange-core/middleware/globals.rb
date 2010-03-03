require 'orange-core/middleware/base'
module Orange::Middleware
  
  class Globals < Base
    def init(*args)
      opts = args.extract_options!.with_defaults(:file => "__ORANGE__/config.yml")
      @file = opts[:file].gsub('__ORANGE__', orange.app_dir)
      @globals = orange[:parser].yaml(@file)
      @globals.each{|k,v| orange.options[k] = v }
    end
    def packet_call(packet)
      packet['orange.globals'] ||= orange.options
      pass packet
    end
    
  end
end