# Monkey Patch the extract_options! stolen from ActiveSupport
class ::Array
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

# Monkey Patch for merging defaults into a hash 
class ::Hash
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
# [:x, :y, :z].inject_hash do |results, letter|
#   results[letter] = rand(100)
# end
#
# => {:x => 32, :y => 63, :z => 91}
module Enumerable
  def inject_hash(hash = {}) 
    inject(hash) {|(h,item)| yield(h,item); h}
  end 
end

# Simple class for evaluating options and allowing us to access them.
module Orange
  class Options
    
    def initialize(*options, &block)
      @options = options.extract_options!
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