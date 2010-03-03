module Orange
  class TestimonialsResource < Orange::ModelResource
    use Orange::Testimonial
    call_me :testimonials
    def afterLoad
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Testimonials')
      orange.register(:stack_loaded) do
        orange[:radius].context.define_tag "testimonials" do |tag|
	     	  if tag.attr["tag"] && model_class.all.count >0
            m = model_class.with_tag(tag.attr["tag"]).first(:offset => rand(model_class.with_tag(tag.attr["tag"]).count)) #selects testimonial based on tag
		      elsif model_class.all.count > 0
        	  m = model_class.first(:offset => rand(model_class.all.count)) #selects a random testimonial
		      end
          unless m.nil?
            orange[:testimonials].testimonial(tag.locals.packet, {:model => m })
          else
            ""
          end
        end
      end
    end
    def testimonial(packet, opts = {})
      do_view(packet, :testimonials, opts)
    end
  end
end