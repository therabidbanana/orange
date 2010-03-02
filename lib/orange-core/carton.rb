require 'dm-core'

module Orange
  # Orange::Carton is the main model class for Orange. It's based on Datamapper.
  # In addition to handling the database interactions, the carton keeps
  # track of declared properties, which is used to create scaffolds.
  #
  # All subclasses should start by declaring the "id" attribute. All models
  # are assumed to have an id attribute by most everything else, so it's 
  # a good idea to have one. Also, we use this to tie in initialization before
  # using the other dsl-ish methods (since these other methods are class level
  # and would happen before initialize ever gets called)
  # 
  # Orange::Carton adds many shortcut methods for adding various datatypes
  # to the model in a more declarative style (`id` vs `property :id, Serial`)
  # 
  # For classes that don't need anything but scaffolding, there's the 
  # as_resource method, which automatically creates a scaffolding resource
  # for the model.
  # 
  # A model that doesn't need scaffolded at all could optionally forgo the carton
  # class and just include DataMapper::Resource. All carton methods are to
  # improve scaffolding capability.
  class Carton
    SCAFFOLD_OPTIONS = [:display_name, :levels] unless defined?(SCAFFOLD_OPTIONS)
    extend ClassInheritableAttributes
    cattr_accessor :scaffold_properties
    
    # Declares a ModelResource subclass that scaffolds this carton
    # The Subclass will have the name of the carton followed by "_Resource"
    def self.as_resource
      name = self.to_s
      eval <<-HEREDOC
      class ::#{name}_Resource < Orange::ModelResource
        use #{name}
      end
      HEREDOC
    end
    
    # Include DataMapper types (required to be able to use Serial)
    include DataMapper::Types
    
    # Do setup of object and declare an id
    def self.id
      include DataMapper::Resource
      property(:id, Serial)
      self.scaffold_properties ||= []
      init
    end
    
    # Stub init method
    def self.init
    end
    
    # Return properties that should be shown for a given context
    def self.form_props(context = :live)
      self.scaffold_properties.select{|p| p[:levels].include?(context)  }
    end
    
    # Helper to wrap properties into admin level
    def self.admin(&block)
      @levels = [:admin, :orange]
      instance_eval(&block)
      @levels = false
    end
    
    # Helper to wrap properties into orange level
    def self.orange(&block)
      @levels = [:orange]
      instance_eval(&block)
      @levels = false
    end
    
    # Helper to wrap properties into front level
    def self.front(&block)
      @levels = [:live, :admin, :orange]
      instance_eval(&block)
      @levels = false
    end
    
    def self.add_scaffold(name, type, dm_type, opts)
      self.scaffold_properties << {:name => name, :type => type, :levels => @levels}.merge(opts) if @levels || opts.has_key?(:levels)
      opts = opts.delete_if{|k,v| SCAFFOLD_OPTIONS.include?(k)} # DataMapper doesn't like arbitrary opts
      self.property(name, dm_type, opts)
    end
    
    # Define a helper for title type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.title(name, opts = {})
      add_scaffold(name, :title, String, opts)
    end
    
    # Define a helper for fulltext type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.fulltext(name, opts = {})
      add_scaffold(name, :fulltext, Text, opts)
    end
    
    # Define a helper for boolean type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.boolean(name, opts = {})
      add_scaffold(name, :boolean, Boolean, opts)
    end
    
    # Define a helper for input type="text" type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.text(name, opts = {})
      add_scaffold(name, :text, String, opts)
    end
    
    # Define a helper for type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.expose(name, opts = {})
      self.scaffold_properties << {:name => name, :type => :text, :levels => @levels, :opts => opts} if @levels
    end
    
    # Define a helper for input type="text" type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.string(name, opts = {})
      self.text(name, opts)
    end
    
    # Override DataMapper to include context sensitivity (as set by helpers)
    def self.scaffold_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      add_scaffold(name, my_type, type, opts)
    end
      
    
    # For more generic cases, use same syntax as DataMapper does.
    # The difference is that this will make it an admin property.
    def self.admin_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      opts[:levels] = [:admin, :orange]
      add_scaffold(name, my_type, type, opts)
    end
    
    # For more generic cases, use same syntax as DataMapper does.
    # The difference is that this will make it a front property.
    def self.front_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      opts[:levels] = [:live, :admin, :orange]
      add_scaffold(name, my_type, type, opts)
    end
    
    # For more generic cases, use same syntax as DataMapper does.
    # The difference is that this will make it an orange property.
    def self.orange_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      opts[:levels] = [:orange]
      add_scaffold(name, my_type, type, opts)
    end
    
  end
end