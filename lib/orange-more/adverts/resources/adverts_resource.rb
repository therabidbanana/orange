module Orange
  class AdvertsResource < Orange::ModelResource
    use OrangeAdvert
    call_me :adverts
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Advertisements')
      orange[:radius].define_tag "adverts" do |tag|
     	  if tag.attr["tag"] && model_class.with_tag(tag.attr["tag"]).count >0
          m = model_class.with_tag(tag.attr["tag"]).first(:offset => rand(model_class.with_tag(tag.attr["tag"]).count)) #selects advert based on tag
	      elsif model_class.all.count > 0
      	  m = model_class.first(:offset => rand(model_class.all.count)) #selects a random advert
	      end
        unless m.nil?
          template = tag.attr["template"] || "adverts"
          orange[:adverts].advert(tag.locals.packet, {:model => m, :template => template})
        else
          ""
        end
      end
    end
    
    def advert(packet, opts = {})
      template = opts[:template].to_sym || :adverts
      do_view(packet, template, opts)
    end
  end
end