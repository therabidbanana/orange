require 'orange/resource'
require 'haml'
require 'yaml'
require 'hpricot'

module Orange
  class Parser < Resource
    
    def yaml(file)
      string = File.read(file)
      out = YAML::load(string)
    end
    
    def haml(file, packet, *vars)
      opts = vars.extract_options!
      opts.merge :orange => orange
      string = File.read(file)
      haml_engine = Haml::Engine.new(string)
      out = haml_engine.render(packet, opts)
    end
    
    def hpricot(html)
      Hpricot(html)
    end
  end 
end