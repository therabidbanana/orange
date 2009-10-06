require 'orange/resource'
require 'rubygems'
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
      resource = opts[:resource].downcase || false
      opts.merge :orange => orange
      if File.exists?('views/'+resource+'/'+file) && resource
        string = File.read('views/'+resource+'/'+file)
      elsif File.exists?('views/'+file)
        string = File.read('views/'+file)
      elsif File.exists?($ORANGE_VIEW + file)
        string = File.read($ORANGE_VIEW + file)
      elsif File.exists?($ORANGE_VIEW + 'default_resource/'+file)
        string = File.read($ORANGE_VIEW+ 'default_resource/'+ file)
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