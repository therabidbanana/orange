module Orange
  class ContactFormsResource < Orange::ModelResource
    use OrangeContactForms
    call_me :contactforms
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Contact Forms')
      orange[:radius].define_tag "contactform" do |tag|
     	  if tag.attr["tag"] && model_class.with_tag(tag.attr["tag"]).count >0
          m = model_class.with_tag(tag.attr["tag"]).first #selects contactform based on tag
	      elsif model_class.all.count > 0
	        if tag.attr["id"]
      	    m = model_class.get(tag.attr["id"])
	        else
	          m = model_class.first
	        end
	      end
        unless m.nil?
          template = tag.attr["template"] || "contactform"
          orange[:contactforms].contactform(tag.locals.packet, {:model => m, :template => template, :id => tag.attr["id"]})
        else
          ""
        end
      end
    end
    
    def contactform(packet, opts = {})
      template = opts[:template].to_sym || :contactform
      do_view(packet, template, opts)
    end
  end
end