require 'dm-core'

module Orange
  class SiteCarton < Carton
    def self.init
      belongs_to :orange_site, 'Orange::Site'
    end
  end
end