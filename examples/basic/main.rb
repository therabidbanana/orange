require 'rubygems'
require '../../lib/orange'
require 'stack'

class Main < Orange::Application
  def stack_init
    @core.template_chooser do |packet|
      if [:admin, :orange].include?(packet['route.context'])
        packet.add_css('admin.css', :module => '_administration_')
        packet.add_js('jquery.js', :module => '_administration_')
        packet.add_js('admin.js', :module => '_administration_')
        orange.fire(:view_admin, packet)
        'admin.haml'
      else 
        packet.add_css('main.css')
        'main.haml'
      end
    end # end do
    orange[:radius, true].context.define_tag "hello" do |tag|
      "Hello #{tag.attr['name'] || 'World'}!"
    end
    
  end
  
end

class Tester < Orange::Resource
  def afterLoad
    orange.register(:wrapped, 100) do |packet|
      # appendHah(packet)
    end
  end
  
  def appendHah(packet)
    packet.html do |html|
      (html / "banana").each { |item|
        item.swap("<a href='http://www.google.com'>Orange is Awesome</a>")
      }
    end
  end
end

class Orange::Site
  admin do
    text :extra
    text :extra2
  end
end