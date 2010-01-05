module Orange
  class PageParts < Resource
    def afterLoad
      orange.add_pulp Orange::Pulp::PageParts
    end
  end
  
  module Pulp::PageParts
    
    def part
      unless packet[:page_parts, false]
        packet[:page_parts] = DefaultHash.new 
        packet[:page_parts].default = ''
      end
      packet[:page_parts]
    end
    
    # Feels like part should be plural, no?
    def parts;    part;     end
    
    
    def add_css(file, opts = {})
      ie = opts[:ie] || false
      mod = opts[:module] || 'public'
        # module set to false gives the root assets dir
      assets = File.join('assets', mod)
      file = File.join('', assets, 'css', file)
      if ie
        part[:ie_css] = part[:ie_css] + "<link rel=\"stylesheet\" href=\"#{file}\" type=\"text/css\" media=\"screen\" charset=\"utf-8\" />"
      else 
        part[:css] = part[:css] + "<link rel=\"stylesheet\" href=\"#{file}\" type=\"text/css\" media=\"screen\" charset=\"utf-8\" />"
      end
    end
    
    def add_js(file, opts = {})
      ie = opts[:ie] || false
      mod = opts[:module] || 'public'
      assets = File.join('assets', mod)
      file = File.join('', assets, 'js', file)
      if ie
        part[:ie_js] = part[:ie_js] + "<script src=\"#{file}\" type=\"text/javascript\"></script>"
      else 
        part[:js] = part[:js] + "<script src=\"#{file}\" type=\"text/javascript\"></script>"
      end
    end
  end
end