module Orange
  class TestimonialsResource < Orange::ModelResource
    use OrangeTestimonial
    call_me :testimonials
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Testimonials')
      orange[:radius].define_tag "testimonials" do |tag|
        packet = tag.locals.packet
     	  if tag.attr["tag"] && for_site(packet).with_tag(tag.attr["tag"]).count >0
          m = for_site(packet).with_tag(tag.attr["tag"]).first(:offset => rand(for_site(packet).with_tag(tag.attr["tag"]).count)) #selects testimonial based on tag
	      elsif for_site(packet).count > 0 && !tag.attr.include?("tag")
      	  m = for_site(packet).first(:offset => rand(for_site(packet).count)) #selects a random testimonial
	      end
        unless m.nil?
          template = tag.attr["template"] || "testimonials"
          orange[:testimonials].testimonial(packet, {:model => m, :template => template})
        else
          ""
        end
      end
    end
    
    def afterNew(packet, obj, params = {})
      obj.orange_site = packet['subsite'].blank? ? packet['site'] : packet['subsite']
    end
    
    def for_site(packet, opts = {})
      site_filtered = model_class.all(:orange_site => packet['subsite'].blank? ? packet['site'] : packet['subsite'])
      if site_filtered.count > 0
        site_filtered
      else
        # Return unfiltered if no site-specific ones
        model_class.all
      end
    end
    
    def testimonial(packet, opts = {})
      template = opts[:template].to_sym || :testimonials
      do_view(packet, template, opts)
    end
  end
end