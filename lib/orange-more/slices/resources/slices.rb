module Orange
  class Slices < Orange::Resource
    call_me :slices
    def afterLoad
      orange.register(:stack_loaded){
        orange[:radius].context.define_tag "slice" do |tag|
          content = ''
          resource = (tag.attr['resource'] || :slices).to_sym
          id = tag.attr['id'] || nil
          mode = (tag.attr['mode'] || tag.attr['chunk'] || (id ? :show : :index )).to_sym
          if orange.loaded?(resource)
            if orange[resource].respond_to?(mode) || resource == :slices
              content << (id ? orange[resource].__send__(mode, tag.locals.packet, :id => id) : orange[resource].__send__(mode, tag.locals.packet))
            else
              content << "resource #{resource} doesn't respond to #{mode}"
            end
          else
            content << "resource #{resource} not loaded"
          end  
          content
        end
      }
    end
    
    
    def method_missing(mode, *args)
      packet = args.first if args.first.kind_of? Orange::Packet
      opts = args.extract_options!
      opts[:resource_name] = 'slices'
      orange[:parser].haml("#{mode.to_s}.haml", packet, opts)
    end
  end
end