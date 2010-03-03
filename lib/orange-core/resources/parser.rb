require 'orange-core/core'
require 'haml'
require 'yaml'

module Orange
  class Parser < Resource
    def afterLoad
      orange.add_pulp Orange::Pulp::ParserPulp
      @template_dirs = [File.join(orange.core_dir, 'templates')]
      @view_dirs = [File.join(orange.core_dir, 'views')]
      Orange.plugins.each{|p| @template_dirs << p.templates if p.has_templates? }
      Orange.plugins.each{|p| @view_dirs << p.views if p.has_views? }
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
      
      string = false
      if temp
        string ||= read_if_exists('templates', file) 
        @template_dirs.each do |templates_dir|
          string ||= read_if_exists(templates_dir, file)
        end
      end
      string ||= read_if_exists('views', resource, file) if resource
      string ||= read_if_exists('views', file)
      @view_dirs.each do |views_dir|
        string ||= read_if_exists(views_dir, resource, file) if resource
        string ||= read_if_exists(views_dir, file)
      end
      string ||= read_if_exists(@view_dirs.first, 'default_resource', file)
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