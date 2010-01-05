require 'rubygems'
require '../../lib/orange'
require 'stack'

class Main < Orange::Application
  def stack_init
    @core.template_chooser do |packet|
      if [:admin, :orange].include?(packet['route.context'])
        packet.add_css('admin.css', :module => '_orange_')
        packet.add_js('admin.js', :module => '_orange_')
        orange.fire(:view_admin, packet)
        'admin.haml'
      else 
        false
      end
    end # end do
  end
  
  
end

class Tester < Orange::Resource
  def afterLoad
    orange.register(:wrapped, 100) do |packet|
      appendHah(packet)
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


class Page < Orange::Carton
  id
  front do
    title :title
    fulltext :body
    fulltext :summary
  end
  admin do
    text :admin_only
  end
  orange do
    text :other_admin
  end
end

class Page_Resource < Orange::ModelResource
  use Page
  def afterLoad
    orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Pages')
  end
end

class Orange::Site
  admin do
    text :extra
    text :extra2
  end
end