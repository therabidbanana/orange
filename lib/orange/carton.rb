require 'dm-core'

module Orange
  class Carton
    
    def self.as_resource
      name = self.to_s
      eval <<-HEREDOC
      class ::#{name}_Resource < Orange::ModelResource
        use #{name}
      end
      HEREDOC
    end
    
    # Info for 
    include DataMapper::Types
    
    def self.id
      include DataMapper::Resource
      self.property(:id, Serial)
      @scaffold_properties = []
      init
    end
    
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
      
    
    # For more generic cases, use same syntax as DataMapper
    # This will make it an admin property though.
    def self.admin_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      @scaffold_properties << {:name => name, :type => my_type, :levels => [:admin, :orange]}.merge(opts)
      property(name, type, opts)
    end
    
    # For more generic cases, use same syntax as DataMapper
    # This will make it a front property though.
    def self.front_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      @scaffold_properties << {:name => name, :type => my_type, :levels => [:live, :admin, :orange]}.merge(opts)
      property(name, type, opts)
    end
    
    # For more generic cases, use same syntax as DataMapper
    # This will make it an orange property though.
    def self.orange_property(name, type, opts = {})
      my_type = type.to_s.downcase.to_sym
      @scaffold_properties << {:name => name, :type => my_type, :levels => [:orange]}.merge(opts)
      property(name, type, opts)
    end
    
  end
end