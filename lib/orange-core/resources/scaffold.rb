require 'orange-core/core'

module Orange
  class Scaffold < Resource
    # Load the scaffold helpers
    def afterLoad
      orange.add_pulp Pulp::ScaffoldHelpers
      Packet.meta_methods(/view_([a-zA-Z_]+)/) do |packet, match, args|
        model = args.shift
        args = args.extract_with_defaults(:mode => match[1].to_sym)
        packet.view(model, args)
      end
      @scaffold_types = {}
      add_scaffold_type(:boolean) do |name, val, opts|
        if opts[:show]
          val ? "true" : "false"
        else
          ret = "<input type='hidden' name='#{opts[:model_name]}[#{name}]' value='0' /><input type='checkbox' name='#{opts[:model_name]}[#{name}]' value='1' #{'checked="checked"' if (val && val != '')}/>"
          ret = "<label for=''>#{opts[:display_name]}</label><br />" + ret if opts[:label]
        end
      end
    end
    
    def add_scaffold_type(type, &block)
      @scaffold_types[type] = Proc.new
    end
    
    def scaffold_attribute(packet, prop, model_name, *args)
      args = args.extract_options!
      args.with_defaults!({:packet => packet, :value => '', :label => false, :show => false})
      val = args[:value]
      label = args[:label]
      show = args[:show]
      name = prop[:name]
      human_readable_name = name.to_s.split('_').each{|w| w.capitalize!}.join(' ')
      display_name = prop[:display_name] || human_readable_name
      return @scaffold_types[prop[:type]].call(name, val, args.with_defaults!(:display_name => display_name, :model_name => model_name)) if @scaffold_types.has_key?(prop[:type])
      unless show
        case prop[:type]
        when :title
          val.gsub!('"', '&quot;')
          ret = "<input class=\"title\" type=\"text\" value=\"#{val}\" name=\"#{model_name}[#{name}]\" />"
        when :text
          val.gsub!('"', '&quot;')
          ret = "<input type=\"text\" value=\"#{val}\" name=\"#{model_name}[#{name}]\" />"
        when :fulltext
          ret = "<textarea name='#{model_name}[#{name}]'>#{val}</textarea>"
        when :boolean
          human_readable_name = human_readable_name + '?'
          ret = "<input type='hidden' name='#{model_name}[#{name}]' value='0' /><input type='checkbox' name='#{model_name}[#{name}]' value='1' #{'checked="checked"' if (val && val != '')}/>"
        when :date
          val.gsub!('"', '&quot;')
          ret = "<input class=\"date\" type=\"text\" value=\"#{val}\" name=\"#{model_name}[#{name}]\" />"
        else
          val.gsub!('"', '&quot;')
          ret = "<input type=\"text\" value=\"#{val}\" name=\"#{model_name}[#{name}]\" />"
        end
        ret = "<label for=''>#{display_name}</label><br />" + ret if label
      else
        case prop[:type]
        when :title
          ret = "<h3 class='#{model_name}-#{name}'>#{val}</h3>"
        when :text
          ret = "<p class='#{model_name}-#{name}'>#{val}</p>"
        when :fulltext
          ret = "<div class='#{model_name}-#{name}'>#{val}</div>"
        else
          ret = "<div class='#{model_name}-#{name}'>#{val}</div>"
        end
      end
      return ret
    end
  end
  
  module Pulp::ScaffoldHelpers
    # Creates a button that appears to be a link but 
    # does form submission with custom method (_method param in POST)
    # This is to avoid issues of a destructive get.
    # @param [String] text link text to show
    # @param [String] link the actual href value of the link
    # @param [String, false] confirm text of the javascript confirm (false for none [default])
    # @param [optional, Array] args array of optional arguments, only opts[:method] defined
    # @option opts [String] method method name (Should be 'DELETE', 'PUT' or 'POST')
    def form_link(text, link, confirm = false, opts = {})
      text = "<img src='#{opts[:img]}' alt='#{text}' />" if opts[:img]
      css = opts[:class]? opts[:class] : 'form_button_link'
      meth = (opts[:method]? "<input type='hidden' name='_method' value='#{opts[:method]}' />" : '')
      if confirm
        "<form action='#{link}' method='post' class='mini' onsubmit='return confirm(\"#{confirm}\")'><button class='link_button'><a href='#' class='#{css}'>#{text}</a></button>#{meth}</form>"
      else
        "<form action='#{link}' method='post' class='mini'><button class='link_button'><a href='#' class='#{css}'>#{text}</a></button>#{meth}</form>"
      end
    end
    
    # Calls view for an orange resource. 
    def view(model_name, *args)
      orange[model_name].view(self, *args)
    end
    
    # Returns a scaffolded attribute
    def view_attribute(prop, model_name, *args)
      orange[:scaffold].scaffold_attribute(self, prop, model_name, *args)
    end
  end
  
end