require 'orange/middleware/base'
module Orange::Middleware
  
  class Database < Base
    def packet_call(packet)
      db = packet['orange.globals']['database'] || 'sqlite3::memory:'
      Orange::load_db!(db)
      pass packet
    end
  end
end