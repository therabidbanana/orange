require 'rubygems'
require '../../lib/orange'
require 'stack'

class Main < Orange::Application
  def stack_init
    @core.template_chooser do |packet|
      if [:admin, :orange].include?(packet['route.context'])
        packet.add_css('admin.css', :module => '_administration_', :position => 0)
        packet.add_js('jquery.js', :module => '_administration_', :position => 0)
        packet.add_js('admin.js', :module => '_administration_')
        orange.fire(:view_admin, packet)
        'admin.haml'
      else   
        packet.add_js('jquery.js', :module => '_administration_', :position => 0)
        packet.add_css('main.css')
        'main.haml'
      end
    end # end do
    orange[:radius, true].define_tag "hello" do |tag|
      "Hello #{tag.attr['name'] || 'World'}!"
    end
    
  end
  
end
