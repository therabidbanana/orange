require 'orange/core'
require 'rubygems'
require 'haml'
require 'yaml'
require 'hpricot'

module Orange
  class Parser < Resource
    
    def yaml(file)
      string = File.read(file)
      string.gsub!('__ORANGE__', orange.app_dir)
      out = YAML::load(string)
    end
    
    def haml(file, packet, *vars)
      opts = vars.extract_options!
      temp = opts.delete(:template)
      resource = (opts[:resource] || '').downcase
      opts.merge :orange => orange
      
      templates_dir = File.join(orange.core_dir, 'templates')
      views_dir = File.join(orange.core_dir, 'views')
      default_dir = File.join(views_dir, 'default_resource')
      
      string = false
      string ||= read_if('templates', file) if temp
      string ||= read_if(templates_dir, file) if temp
      string ||= read_if('views', resource, file) if resource
      string ||= read_if('views', file)
      string ||= read_if(views_dir, file)
      string ||= read_if(views_dir, 'default_resource', file)
      raise LoadError, "Couldn't find haml file '#{file}" unless string
      
      haml_engine = Haml::Engine.new(string)
      out = haml_engine.render(packet, opts)
    end
    
    def read_if(*args)
      return File.read(File.join(*args)) if File.exists?(File.join(*args))
      false
    end
    
    def hpricot(text)
      Hpricot(text)
    end
  end 
  
end