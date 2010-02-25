require 'orange-core/middleware/base'
module Orange::Middleware
  
  class Database < Base
    def init(opts = {})
      opts = opts.with_defaults(:migration_url => (orange.options[:development_mode] ? '/__ORANGE_DB__/migrate' : false))
      orange.mixin Orange::Mixins::DBLoader
      db = orange.options['database'] || 'sqlite3::memory:'
      orange.load_db!(db)
      orange.upgrade_db!
      @options = opts
    end
    def packet_call(packet)
      path = packet['route.path'] || packet.request.path_info
      if @options[:migration_url] && @options[:migration_url] == path
        orange.migrate_db!
        packet.reroute('/')
      end
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