module Orange
  class TestimonialsResource < Orange::ModelResource
    use OrangeTestimonial
    call_me :testimonials
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Testimonials')
      orange[:radius].define_tag "testimonials" do |tag|
     	  if tag.attr["tag"] && model_class.with_tag(tag.attr["tag"]).count >0
          m = model_class.with_tag(tag.attr["tag"]).first(:offset => rand(model_class.with_tag(tag.attr["tag"]).count)) #selects testimonial based on tag
	      elsif model_class.all.count > 0
      	  m = model_class.first(:offset => rand(model_class.all.count)) #selects a random testimonial
	      end
        unless m.nil?
          template = tag.attr["template"] || "testimonials"
          orange[:testimonials].testimonial(tag.locals.packet, {:model => m, :template => template})
        else
          ""
        end
      end
    end
    
    def testimonial(packet, opts = {})
      template = opts[:template].to_sym || :testimonials
      do_view(packet, template, opts)
    end
  end
end