require 'orange-core/middleware/base'
module Orange::Middleware
  
  class Database < Base
    def init(*args)
      orange.mixin Orange::Mixins::DBLoader
      db = orange.options['database'] || 'sqlite3::memory:'
      orange.load_db!(db)
      orange.upgrade_db!
    end
    def packet_call(packet)
      pass packet
    end
  end
  
end

module Orange::Mixins::DBLoader
  def load_db!(url)
    DataMapper.setup(:default, url)
  end
  
  def migrate_db!
    DataMapper.auto_migrate!
  end
  
  def upgrade_db!
    DataMapper.auto_upgrade!
  end
  
end