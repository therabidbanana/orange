module Orange
  # Admin resource is a resource to help in building administration
  # panels. 
  class AdminResource < Resource
    def afterLoad
      @links = {}
    end
    
    def add_link(section, *args)
      opts = args.extract_with_defaults(:position => 0)
      @links[section] = [] unless @links.has_key?(section)
      @links[section].insert(opts.delete(:position), opts)
      @links[section].compact!
      @links[section].uniq!
    end
    
    def links(packet)
      @links.each do |k,section|
        section.each {|link| 
          link[:href] = orange[:mapper].route_to(packet, link[:resource], link[:resource_args])
        }
      end
    end
  end
end