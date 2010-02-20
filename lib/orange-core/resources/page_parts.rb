require 'orange-core/resource'
module Orange
  class PageParts < Resource
    def afterLoad
      orange.add_pulp Orange::Pulp::PageParts
    end
    
    def part(packet)
      unless packet[:page_parts, false]
        packet[:page_parts] = DefaultHash.new 
        packet[:page_parts].default = ''
      end
      packet[:page_parts]
    end
    
    
    def add_css(packet, file, opts = {})
      ie = opts[:ie] || false
      mod = opts[:module] || 'public'
        # module set to false gives the root assets dir
      assets = File.join('assets', mod)
      file = File.join('', assets, 'css', file)
      unless packet[:css_files, []].include?(file)
        if ie
          part(packet)[:ie_css] = part(packet)[:ie_css] + "<link rel=\"stylesheet\" href=\"#{file}\" type=\"text/css\" media=\"screen\" charset=\"utf-8\" />"
        else 
          part(packet)[:css] = part(packet)[:css] + "<link rel=\"stylesheet\" href=\"#{file}\" type=\"text/css\" media=\"screen\" charset=\"utf-8\" />"
        end
        packet[:css_files] ||= []
        packet[:css_files] << file
      end
    end
    
    def add_js(packet, file, opts = {})
      ie = opts[:ie] || false
      mod = opts[:module] || 'public'
      assets = File.join('assets', mod)
      file = File.join('', assets, 'js', file)
      unless packet[:js_files, []].include?(file)
        if ie
          part(packet)[:ie_js] = part(packet)[:ie_js] + "<script src=\"#{file}\" type=\"text/javascript\"></script>"
        else 
          part(packet)[:js] = part(packet)[:js] + "<script src=\"#{file}\" type=\"text/javascript\"></script>"
        end
        packet[:js_files] ||= []
        packet[:js_files] << file
      end
    end
  end
  
  module Pulp::PageParts
    def part
      orange[:page_parts].part(packet)
    end
    
    # Feels like part should be plural, no?
    def parts;    part;     end
    
    
    def add_css(file, opts = {})
      orange[:page_parts].add_css(packet, file, opts)
    end
    
    def add_js(file, opts = {})
      orange[:page_parts].add_js(packet, file, opts)
    end
  end
end