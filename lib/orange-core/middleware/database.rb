require 'orange-core/middleware/base'
module Orange::Middleware
  
  class Database < Base
    def init(*args)
      orange.mixin Orange::Mixins::DBLoader
    end
    def packet_call(packet)
      db = packet['orange.globals']['database'] || 'sqlite3::memory:'
      orange.load_db!(db)
      pass packet
    end
  end
  
end

module Orange::Mixins::DBLoader
  def load_db!(url)
    DataMapper.setup(:default, url)
    DataMapper.auto_upgrade!
  end
end