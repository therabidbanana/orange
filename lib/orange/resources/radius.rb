require 'radius'

module Orange
  # Radius resource is for exposing the Radius context
  # and allowing parsing.
  class Radius < Resource
    def afterLoad
      @context = ::Radius::Context.new
    end
    
    def context
      @context
    end
    
    def parse(packet)
      content = packet[:content, false]
      unless content.blank? 
        parser = ::Radius::Parser.new(context, :tag_prefix => 'o')
        packet[:content] = parser.parse(content, packet)
      end
    end
  end
end

module Radius
  #
  # The Radius parser. Initialize a parser with a Context object that
  # defines how tags should be expanded. See the QUICKSTART[link:files/QUICKSTART.html]
  # for a detailed explaination of its usage.
  #
  class Parser
    def parse(string, packet = false)
      @stack = [ParseContainerTag.new { |t| t.contents.to_s }]
      tokenize(string)
      stack_up(packet)
      @stack.last.to_s
    end
 
    protected
    
    def stack_up(packet = false)
      @tokens.each do |t|
        if t.is_a? String
          @stack.last.contents << t
          next
        end
        case t[:flavor]
        when :open
          @stack.push(ParseContainerTag.new(t[:name], t[:attrs]))
        when :self
          @stack.last.contents << ParseTag.new {@context.render_tag(t[:name], t[:attrs], packet)}
        when :close
          popped = @stack.pop
          raise WrongEndTagError.new(popped.name, t[:name], @stack) if popped.name != t[:name]
          popped.on_parse { |b| @context.render_tag(popped.name, popped.attributes, packet) { b.contents.to_s } }
          @stack.last.contents << popped
        when :tasteless
          raise TastelessTagError.new(t, @stack)
        else
          raise UndefinedFlavorError.new(t, @stack)
        end
      end
      raise MissingEndTagError.new(@stack.last.name, @stack) if @stack.length != 1
    end
  end
  class Context

    # Returns the value of a rendered tag. Used internally by Parser#parse.
    def render_tag(name, attributes = {}, packet = false, &block)
      if name =~ /^(.+?):(.+)$/
        render_tag($1) { render_tag($2, attributes, packet, &block) }
      else
        tag_definition_block = @definitions[qualified_tag_name(name.to_s)]
        if tag_definition_block
          stack(name, attributes, packet, block) do |tag|
            tag_definition_block.call(tag).to_s
          end
        else
          tag_missing(name, attributes, &block)
        end
      end
    end
    # A convienence method for managing the various parts of the
    # tag binding stack.
    def stack(name, attributes, packet, block)
      previous = @tag_binding_stack.last
      previous_locals = previous.nil? ? @globals : previous.locals
      locals = DelegatingOpenStruct.new(previous_locals)
      locals.packet = packet
      binding = TagBinding.new(self, locals, name, attributes, block)
      @tag_binding_stack.push(binding)
      result = yield(binding)
      @tag_binding_stack.pop
      result
    end
  end
end
