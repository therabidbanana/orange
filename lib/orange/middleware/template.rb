require 'orange/core'
require 'orange/middleware/base'

module Orange::Middleware
  class Template < Base
    def init(*args)
      @core.add_pulp(Orange::Pulp::Template)
      @core.class.mixin(Orange::Mixins::Template) 
      @core.template_chooser do |packet|
        if packet['route.context'] == :admin
          packet.add_css('admin.css', :module => '_orange_')
          'admin.haml'
        else
          false
        end
      end
    end
    
    def packet_call(packet)
      packet['template.file'] = orange.template_for packet
      status, headers, content = pass packet
      if needs_wrapped?(packet)
        content = wrap(packet, content)
      end
      [status, headers, content]
    end
    
    def needs_wrapped?(packet)
      packet['template.file'] && !packet['template.disable']
    end
    
    def wrap(packet, content = false)
      content = packet.content unless content
      content = content.join
      content = orange[:parser].haml(packet['template.file'], packet, :wrapped_content => content, :template => true)
      [content]
    end
  end
end

module Orange::Pulp::Template
  def wrap
    packet[:content] = orange[:parser].haml(packet['template.file'], packet, :wrapped_content => packet[:content], :template => true)
  end
end

module Orange::Mixins::Template
  def template_for(packet)
    @template_chooser.call(packet)
  end
  def template_chooser(&block)
    @template_chooser = Proc.new
  end
end