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
      self.property(:id, Serial)
      @scaffold_properties = []
      init
    end
    
    # Stub init method
    def self.init
    end
    
    # Return properties that should be shown for a given context
    def self.form_props(context)
      @scaffold_properties.select{|p| p[:levels].include?(context)  }
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
    
    # Define a helper for title type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.title(name, opts = {})
      @scaffold_properties << {:name => name, :type => :title, :levels => @levels}.merge(opts) if @levels
      self.property(name, String, opts)
    end
    
    # Define a helper for fulltext type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.fulltext(name, opts = {})
      @scaffold_properties << {:name => name, :type => :fulltext, :levels => @levels, :opts => opts} if @levels
      self.property(name, Text, opts)
    end
    
    # Define a helper for input type="text" type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.text(name, opts = {})
      @scaffold_properties << {:name => name, :type => :text, :levels => @levels, :opts => opts} if @levels
      self.property(name, String, opts)
    end
    
    # Define a helper for input type="text" type database stuff
    # Show in a context if wrapped in one of the helpers
    def self.string(name, opts = {})
      self.text(name, opts)
    end
    
    # Override DataMapper to include context sensitivity (as set by helpers)
    def self.property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      @scaffold_properties << {:name => name, :type => my_type, :levels => @levels}.merge(opts) if @levels
      property(name, type, opts)
    end
      
    
    # For more generic cases, use same syntax as DataMapper does.
    # The difference is that this will make it an admin property.
    def self.admin_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      @scaffold_properties << {:name => name, :type => my_type, :levels => [:admin, :orange]}.merge(opts)
      property(name, type, opts)
    end
    
    # For more generic cases, use same syntax as DataMapper does.
    # The difference is that this will make it a front property.
    def self.front_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      @scaffold_properties << {:name => name, :type => my_type, :levels => [:live, :admin, :orange]}.merge(opts)
      property(name, type, opts)
    end
    
    # For more generic cases, use same syntax as DataMapper does.
    # The difference is that this will make it an orange property.
    def self.orange_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      @scaffold_properties << {:name => name, :type => my_type, :levels => [:orange]}.merge(opts)
      property(name, type, opts)
    end
    
  end
end