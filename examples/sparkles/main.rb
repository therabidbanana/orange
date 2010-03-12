require 'rubygems'
require '../../lib/orange'
require 'stack'

class Main < Orange::Application
  def stack_init
    @core.template_chooser do |packet|
      if [:admin, :orange].include?(packet['route.context'])
        packet.add_css('sparkles-admin.css')
        packet.add_css('smoothness/jquery-ui-1.7.2.custom.css')
        packet.add_js('jquery-1.4.1.min.js')
        packet.add_js('markitup/sets/markdown/set.js')
        packet.add_js('markitup/jquery.markitup.pack.js')
        packet.add_js('autoresize.jquery.min.js')
        packet.add_js('jquery-ui-1.7.2.custom.min.js')
        packet.add_js('jquery.form.js')
        packet.add_js('jquery.tools.min.js')
        orange.fire(:view_admin, packet)
        'admin.haml'
      else   
        packet.add_js('jquery.js', :module => '_administration_')
        packet.add_css('main.css')
        'main.haml'
      end
    end # end do
    orange[:radius, true].context.define_tag "hello" do |tag|
      "Hello #{tag.attr['name'] || 'World'}!"
    end
    
  end
  
end

module SparkleHelpers
  def delete_button(link)
    return "<form method='POST' class='delete-form' action='#{link}'><input name='_method' type='hidden' value='delete' /><a class='grey-button delete-button' onclick='$(this).parent(\'form\').submit()' href='#{link}'>Delete</a></form>"
  end
  def move_button(dir, route)
    action = packet.route_to(:sitemap, route.id, dir)
    case dir
    when "outdent"
      disabled = true unless route.level > 1 
    when "indent"
      disabled = true unless route.previous_sibling
    when "higher"
      disabled = true unless route.previous_sibling
    when "lower"
      disabled = true unless route.next_sibling
    end
    unless disabled
      return "<form method='POST' class='move-arrow' action='#{action}'><a href='#{action}' class='move-#{dir}' onclick=''><img src='/assets/public/images/move-#{dir}.png' /></a></form>"
    else return "<a class='move-#{dir} move-disabled'><img src='/assets/public/images/move-#{dir}-disabled.png' /></a>"
    end
  end
end