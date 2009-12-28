require 'orange/resources/routable_resource'

module Orange
  class ModelResource < RoutableResource
    extend ClassInheritableAttributes
    # Defines a model class as an inheritable class attribute and also an instance
    # attribute
    cattr_inheritable :model_class
    attr_accessor :model_class
    
    # Tells the Model resource which Carton class to scaffold
    # @param [Orange::Carton] my_model_class class name of the carton class to scaffold
    def self.use(my_model_class)
      self.model_class = my_model_class
    end
    
    # Overrides the instantiation of new Resource object to set instance model
    # class to the class-level model class defined by #use
    def self.new(*args, &block)
      me = super(*args, &block)
      me.model_class = self.model_class 
      me
    end
    
    # Views a packet by calling method defined as opts[:mode].
    # Defaults mode to show or list, if it can't find opts[:mode].
    # Decision between show or list is determined by whether an id has been chosen.
    # An id is set in opts[:id], or extracted from the packet['route.resource_id']. 
    # Calling view is equivalent to calling a viewable method directly, view just
    # sets up safe defaults so method missing errors are less likely.
    # @param [Orange::Packet] packet the packet calling view on this resource
    def view(packet, *args)
      opts = args.last || {}
      resource_id = opts[:id] || packet['route.resource_id', false]
      mode = opts[:mode] || packet['route.resource_action'] || 
        (resource_id ? :show : :index)
      self.__send__(mode, packet, *args)
    end
    
    # Renders a view, with all options set for haml to access.
    # Calls #view_opts to generate the haml options. 
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [optional, Array] args the args array
    # @return [String] haml parsed string to be placed in packet[:content] by #route
    def do_view(packet, mode, *args)
      haml_opts = view_opts(packet, mode, false, *args)
      orange[:parser].haml("#{mode.to_s}.haml", packet, haml_opts)
    end
    
    # Renders a view, with all options set for haml to access. Same as do_view, but
    # calls #view_opts with is_list set to true to generate the haml options.
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [optional, Array] args the args array
    # @return [String] haml parsed string to be placed in packet[:content] by #route
    def do_list_view(packet, mode, *args)
      haml_opts = view_opts(packet, mode, true, *args)
      orange[:parser].haml("#{mode.to_s}.haml", packet, haml_opts)
    end
    
    # Returns the options for including in template rendering. All keys passed in the args array
    # will automatically be local variables in the haml template.
    # In addition, the props, resource, and model_name variables will be available.
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [boolean] is_list whether we want a list or not (view_opts will automatically look up
    #   a single object or a list of objects, so we need to know which)
    # @param [optional, Array] args the args array
    # @return [Hash] hash of options to be used
    def view_opts(packet, mode, is_list, *args)
      opts = args.extract_options!.with_defaults({:path => ''})
      props = model_class.form_props(packet['route.context'])
      resource_id = opts[:id] || packet['route.resource_id'] || false
      all_opts = {:props => props, :resource => self.class.to_s, :model_name => @my_orange_name}.merge!(opts)
      all_opts.with_defaults! :model => find_one(packet, mode, resource_id) unless is_list
      all_opts.with_defaults! :list => find_list(packet, mode) if is_list
      all_opts.with_defaults! find_extras(packet, mode)
      all_opts
    end
    
    # Returns a single object found by the model class, given an id. 
    # If id isn't given, we return false.
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [Numeric] id the id to lookup on the model class
    # @return [Object] returns an object of type set by #use, if one found with same id
    def find_one(packet, mode, id = false)
      return false unless id
      model_class.get(id) 
    end
    
    # Returns a list of all objects found by the model class
    # If none, returns an empty array
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [Numeric] id the id to lookup on the model class
    # @return [Enumerable] returns a collection of objects of type set by #use
    def find_list(packet, mode)
      model_class.all || []
    end
    
    # Returns a hash of extra options to be set and made available by the haml parser.
    # Overriding this method is useful for passing extra bits of info to rendering
    # for certain view modes without rewriting all of the other scaffolding
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @return [Hash] a hash of extras to be included in the rendering
    def find_extras(packet, mode)
      {}
    end
    
    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def new(packet, *opts)
      if packet.request.post?
        model_class.new(packet.request.params[@my_orange_name.to_s]).save
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    # Deletes an object specified by packet['route.resource_id'], then reroutes to main
    # @param [Orange::Packet] packet the packet being routed
    def delete(packet, *opts)
      if packet.request.delete?
        m = model_class.get(packet['route.resource_id'])
        m.destroy! if m
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    # Saves updates to an object specified by packet['route.resource_id'], then reroutes to main
    # @param [Orange::Packet] packet the packet being routed
    def save(packet, *opts)
      if packet.request.post?
        m = model_class.get(packet['route.resource_id'])
        if m
          m.update(packet.request.params[@my_orange_name.to_s])
        else 
        end
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    # Calls #do_view with :show mode
    # @param [Orange::Packet] packet the packet being routed
    def show(packet, *opts)
      do_view(packet, :show, *opts)
    end
    
    # Calls #do_view with :edit mode
    # @param [Orange::Packet] packet the packet being routed
    def edit(packet, *opts)
      do_view(packet, :edit, *opts)
    end
    
    # Calls #do_view with :create mode
    # @param [Orange::Packet] packet the packet being routed
    def create(packet, *opts)
      do_view(packet, :create, *opts)
    end
    
    # Calls #do_view with :table_row mode
    # @param [Orange::Packet] packet the packet being routed
    def table_row(packet, *opts)
      do_view(packet, :table_row, *opts)
    end
    
    # Calls #do_list_view with :list mode
    # @param [Orange::Packet] packet the packet being routed
    def list(packet, *opts)
      do_list_view(packet, :list, *opts)
    end
    
    # Calls #do_list_view with :list mode. 
    # @param [Orange::Packet] packet the packet being routed
    def index(packet, *opts)
      do_list_view(packet, :list, *opts)
    end
  
  end
  
  class Packet
    # Adds view_[mode_name] magic methods to the packet
    meta_methods(/view_([a-zA-Z_]+)/) do |packet, match, args|
      model = args.shift
      args = args.extract_with_defaults(:mode => match[1].to_sym)
      packet.view(model, args)
    end
    
    # Creates a button that appears to be a link but 
    # does form submission with custom method (_method param in POST)
    # This is to avoid issues of a destructive get.
    # @param [String] text link text to show
    # @param [String] link the actual href value of the link
    # @param [String, false] confirm text of the javascript confirm (false for none [default])
    # @param [optional, Array] args array of optional arguments, only opts[:method] defined
    # @option opts [String] method method name (Should be 'DELETE', 'PUT' or 'POST')
    def form_link(text, link, confirm = false, *args)
      opts = args.extract_options!
      meth = (opts[:method]? "<input type='hidden' name='_method' value='#{opts[:method]}' />" : '')
      if confirm
        "<form action='#{link}' method='post' class='mini' onsubmit='return confirm(\"#{confirm}\")'><button class='link_button'><a href='#'>#{text}</a></button>#{meth}</form>"
      else
        "<form action='#{link}' method='post' class='mini'><button class='link_button'><a href='#'>#{text}</a></button>#{meth}</form>"
      end
    end
    
    # Calls view for an orange resource. 
    def view(model_name, *args)
      orange[model_name].view(self, *args)
    end
    
    # Returns a scaffolded attribute
    def view_attribute(prop, model_name, *args)
      args = args.extract_options!
      val = args[:value] || ''
      label = args[:label] || false
      show = args[:show] || false
      name = prop[:name]
      unless show
        case prop[:type]
        when :title
          ret = "<input class='title' type='text' value='#{val}' name='#{model_name}[#{name}]' />"
        when :text
          ret = "<input type='text' value='#{val}' name='#{model_name}[#{name}]' />"
        when :fulltext
          ret = "<textarea name='#{model_name}[#{name}]'>#{val}</textarea>"
        else
          ret = "<input type='text' value='#{val}' name='#{model_name}[#{name}]' />"
        end
        ret = "<label for=''>#{name}</label><br />" + ret if label
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
      ret
    end
  end
end