require 'orange-core/carton'

module Orange
  # Defines a carton that belongs to a specific site.
  # (Subclasses should be sure to call super if they override init, since
  # it is what defines the relationship)
  class SiteCarton < Carton
    def self.init
      belongs_to :orange_site, 'Orange::Site'
    end
  end
end