require 'orange/core'
require 'haml'
require 'yaml'

module Orange
  class Parser < Resource
    def afterLoad
      orange.add_pulp Orange::Pulp::ParserPulp
    end
    
    def yaml(file)
      string = File.read(file)
      string.gsub!('__ORANGE__', orange.app_dir)
      out = YAML::load(string)
    end
    
    def haml(file, packet, *vars, &block)
      opts = vars.extract_options!
      temp = opts.delete(:template)
      opts[:resource_name] = opts[:resource].orange_name.to_s if 
          opts[:resource] && opts[:resource].respond_to?(:orange_name)
      resource = (opts[:resource_name] || '').downcase
      opts.merge :orange => orange
      
      templates_dir = File.join(orange.core_dir, 'templates')
      views_dir = File.join(orange.core_dir, 'views')
      string = false
      string ||= read_if_exists('templates', file) if temp
      string ||= read_if_exists(templates_dir, file) if temp
      string ||= read_if_exists('views', resource, file) if resource
      string ||= read_if_exists('views', file)
      string ||= read_if_exists(views_dir, resource, file) if resource
      string ||= read_if_exists(views_dir, 'default_resource', file)
      string ||= read_if_exists(views_dir, file)
      raise LoadError, "Couldn't find haml file '#{file}'" unless string
      
      haml_engine = Haml::Engine.new(string)
      out = haml_engine.render(packet, opts, &block)
    end
    
    def read_if_exists(*args)
      return File.read(File.join(*args)) if File.exists?(File.join(*args))
      false
    end
    
    def hpricot(text)
      require 'hpricot'
      Hpricot(text)
    end
  end 
  
  module Pulp::ParserPulp
    def html(&block)
      if block_given?
        unless(packet[:content].blank?)
          doc = orange[:parser].hpricot(packet[:content])
          yield doc
          packet[:content] = doc.to_s
        end
      end
    end
  end
end