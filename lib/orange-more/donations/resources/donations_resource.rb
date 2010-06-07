module Orange
  class DonationsResource < Orange::ModelResource
    use OrangeDonation
    call_me :donations
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Donations')
      orange[:radius].define_tag "donations" do |tag|
        template = tag.attr["template"] || "donate_form"
        orange[:donations].form(tag.locals.packet, {:template => template})
      end
    end
    
    def form(packet, opts = {})
      template = opts[:template].to_sym || :donate_form
      packet['route.return_path'] = packet.request.path.to_s
      do_view(packet, template, opts)
    end
    
    def donate_cancel(packet, opts = {})
      id = packet.session['donation_id']
      m = model_class.get(id)
      m.destroy!
      packet.flash['error'] = "There was an issue completing the process on Paypal."
      packet.reroute((packet.flash('reroute.to') || '/'))
    end
    
    def process(packet, opts = {})
      params = packet.request.params
      route = params.delete('r')
      params['donation_amount'] = params['donation_amount'].sub(/\$/, '')
      if params['donor_phone'] == '' && packet.request.post? && params['donation_amount'] != '' && params['donation_amount'].to_f > 0
        template = "paypal_form"
        params.delete('donor_phone')
        obj = self.new(packet, {:no_reroute => true, :params => params})
        packet.session['donation_id'] = obj.id
        packet.flash['reroute.to'] = route
        opts[:donation_amount] = params['donation_amount']
        opts[:paypal_id] = orange.options['paypal_id'] || ''
        do_view(packet, template, opts)
      else
        packet.flash['error'] = "An error has occurred. Please try your submission again."
        packet.reroute(route)
      end
    end
    
    def donate_success(packet, opts = {})
      template = "donate_thanks"
      do_view(packet, template, opts)
    end
  end
end