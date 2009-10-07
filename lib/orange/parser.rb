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
      temp = opts.delete(:template)
      resource = (opts[:resource] || '').downcase
      opts.merge :orange => orange
      if temp && File.exists?('templates/'+file)
        string = File.read('templates/'+file)
      elsif temp && File.exists?($ORANGE_PATH + '/templates/' + file)
        string = File.read($ORANGE_PATH + '/templates/' + file)
      elsif File.exists?('views/'+resource+'/'+file) && resource
        string = File.read('views/'+resource+'/'+file)
      elsif File.exists?('views/'+file)
        string = File.read('views/'+file)
      elsif File.exists?($ORANGE_VIEWS + "/" + file)
        string = File.read($ORANGE_VIEWS + "/" + file)
      elsif File.exists?($ORANGE_VIEWS + '/default_resource/'+file)
        string = File.read($ORANGE_VIEWS+ '/default_resource/'+ file)
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