require 'mail'

module Orange
  class ContactFormsResource < Orange::ModelResource
    use OrangeContactForms
    call_me :contactforms
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Contact Forms')
      orange[:radius].define_tag "contactform" do |tag|
     	  if tag.attr["name"] && model_class.named(tag.attr["name"]).count >0
          m = model_class.named(tag.attr["name"]).first #selects contactform based on title
	      elsif model_class.all.count > 0
	        if tag.attr["id"]
      	    m = model_class.get(tag.attr["id"])
	        else
	          m = model_class.first
	        end
	      end
        unless m.nil?
          template = tag.attr["template"] || "contactform"
          orange[:contactforms].contactform(tag.locals.packet, {:model => m, :template => template, :id => m.id})
        else
          ""
        end
      end
    end
    
    def contactform(packet, opts = {})
      template = opts[:template].to_sym || :contactform
      packet['route.return_path'] = packet.request.path.to_s
      do_view(packet, template, opts)
    end
    
    def mailer(packet, opts = {})
      params = packet.request.params
      route = params['r']
      if params['contact_phone'] != ''
        packet.flash['error'] = "An error has occurred. Please try your submission again."
        packet.reroute(route)
      end
      path = packet['route.path']
      parts = path.split('/')
      form = model_class.get(parts.last.to_i)
      mail = Mail.new do
        from "WNSF <info@wnsf.org>"
        to form.to_address
        subject 'E-mail contact from WNSF.org - '+form.title
        body "From: "+params['contact_from']+" ("+params['contact_email_address']+")\n\nMessage:\n"+params['contact_message']
      end
      mail.delivery_method :sendmail
      mail.deliver
      packet.flash['error'] = "Thanks for your submission. We will contact you as soon as possible."
      packet.reroute(route)
    end
  end
end