# Monkey Patch the extract_options! stolen from ActiveSupport
class ::Array #:nodoc:
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
  def extract_with_defaults(defaults)
    extract_options!.with_defaults(defaults)
  end
end

# Monkey Patch for merging defaults into a hash 
class ::Hash #:nodoc:
  def with_defaults(defaults)
    self.merge(defaults){ |key, old, new| old.nil? ? new : old } 
  end
  def with_defaults!(defaults)
    self.merge!(defaults){ |key, old, new| old.nil? ? new : old } 
  end
end



# Monkey patch for awesome array -> hash conversions
# use:
#
#   [:x, :y, :z].inject_hash do |results, letter|
#     results[letter] = rand(100)
#   end
#
#   # => {:x => 32, :y => 63, :z => 91}
module Enumerable #:nodoc:
  def inject_hash(hash = {}) 
    inject(hash) {|(h,item)| yield(h,item); h}
  end 
end

module ClassInheritableAttributes #:nodoc:
  def cattr_inheritable(*args)
    @cattr_inheritable_attrs ||= [:cattr_inheritable_attrs]
    @cattr_inheritable_attrs += args
    args.each do |arg|
      class_eval %(
        class << self; attr_accessor :#{arg} end
      )
    end
    @cattr_inheritable_attrs
  end

  def inherited(subclass)
    @cattr_inheritable_attrs.each do |inheritable_attribute|
      instance_var = "@#{inheritable_attribute}" 
      subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
    end
  end
end

module Orange
  
  # Class that extends hash so that [] can have an optional second attribute
  class DefaultHash < ::Hash
    def [](key, my_default = nil)
      my_default = self.default if my_default.nil?
      self.has_key?(key) ? super(key) : my_default
    end
  end
  
  # This class acts as a simple sink for ignoring messages, it will return itself
  # for any message call. Orange::Core can optionally return this when trying 
  # to access resources so that you can make method calls to a resource that 
  # might not be really there. It will silently swallow any errors that might arrise,
  # so this should be used with caution.
  class Ignore
    def method_missing(name, *args, &block)
      return self
    end
  end
  
  # Simple class for evaluating options and allowing us to access them.
  class Options
    
    def initialize(*options, &block)
      @options = options.extract_options!
      @options ||= {}
      instance_eval(&block) if block_given?
    end
    
    def hash
      @options
    end

    def method_missing(key, *args)
      return (@options[key.to_s.gsub(/\?$/, '').to_sym].eql?(true)) if key.to_s.match(/\?$/)
      if args.empty?
        @options[key.to_sym]
      elsif(key.to_s.match(/\=$/))
        @options[key.to_s.gsub(/\=$/, '').to_sym] = (args.size == 1 ? args.first : args)
      else
        @options[key.to_sym] = (args.size == 1 ? args.first : args)
      end
    end
  end
end

class Object #:nodoc:
  # An object is blank if it's false, empty, or a whitespace string.
  # For example, "", "   ", +nil+, [], and {} are blank.
  #
  # This simplifies
  #
  #   if !address.nil? && !address.empty?
  #
  # to
  #
  #   if !address.blank?
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class NilClass #:nodoc:
  def blank?
    true
  end
end

class FalseClass #:nodoc:
  def blank?
    true
  end
end

class TrueClass #:nodoc:
  def blank?
    false
  end
end

class Array #:nodoc:
  alias_method :blank?, :empty?
end

class Hash #:nodoc:
  alias_method :blank?, :empty?
end

class String #:nodoc:
  def blank?
    self !~ /\S/
  end
end

class Numeric #:nodoc:
  def blank?
    false
  end
end