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
      if File.exists?(file)
        string = File.read(file)
      elsif File.exists?($ORANGE_VIEW + file)
        string = File.read($ORANGE_VIEW + file)
      else 
        raise LoadError, "Couldn't find haml file '#{file}'"
      end
      haml_engine = Haml::Engine.new(string)
      out = haml_engine.render(packet, opts)
    end
    
    def hpricot(text)
      Hpricot(text)
    end
  end 
  
end