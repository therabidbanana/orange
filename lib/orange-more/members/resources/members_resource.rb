require 'spreedly'

module Orange
  class MembersResource < Orange::ModelResource
    use OrangeMember
    call_me :members
    def stack_init
      options[:spreedly_key] = orange.options['spreedly_key'] || false
      options[:spreedly_plan] = orange.options['spreedly_plan'] || false
      options[:spreedly_site] = orange.options['spreedly_site'] || false
      Spreedly.configure(options[:spreedly_site], options[:spreedly_key]) if options[:spreedly_key]
      
      orange[:admin, true].add_link("Settings", :resource => @my_orange_name, :text => 'Members')
      orange[:radius, true].define_tag "if_member" do |tag|
        packet = tag.locals.packet
        if packet.session["member"]
          tag.expand
        else
          if(tag.attr["else_view"]) 
            orange[:members].do_view(packet, tag.attr["else_view"].to_sym)
          else
            ""
          end
        end
      end
      orange[:radius, true].define_tag "if_paid_member" do |tag|
        packet = tag.locals.packet
        if packet.session["member"] && orange[:members].paid?(packet, packet.session["member"])
          tag.expand
        else
          if(tag.attr["else_view"]) 
            orange[:members].do_view(packet, tag.attr["else_view"].to_sym)
          else
            ""
          end
        end
      end
      orange[:radius, true].define_tag "unless_member" do |tag|
        packet = tag.locals.packet
        unless packet.session["member"]
          tag.expand
        else
          ""
        end
      end
    end
    
    def paid?(packet, member)
      unless member.is_a? model_class
        member = model_class.get(member)
      end
      subscriber = Spreedly::Subscriber.find(member.id)
      subscriber ? subscriber.active? : false
    end
    
    def subscription_url(packet, member)
      unless member.is_a? model_class
        member = model_class.get(member)
      end
      Spreedly.subscribe_url(member.id, options[:spreedly_plan])
    end
    
    def login(packet, opts = {})
      if packet.request.post?
        params = packet.request.params["members"]
        login = params["login_email"]
        password = params["login_password"]
        tester = model_class.new({:password => password})
        member = model_class.first({:email => login})
        if member && tester.hashed_password == member.hashed_password
          packet.session["member"] = member.id
          packet.reroute(@my_orange_name, :orange, :profile)
        else
          packet.flash("error", "Invalid email or password")
          do_view(packet, :login, opts)
        end
      else
        do_view(packet, :login, opts)
      end
    end
    
    def register(packet, opts = {})
      if packet.request.post?
        params = packet.request.params["members"]
        
        member = model_class.first(:email => params["email"])
        if member
          # Existing member... do they already have password?
          if member.hashed_password.blank?
            # A member who is part of the mailing list, but hasn't
            # set a password
            email = params.delete("email")
            save(packet, {:resource_id => member.id, :params => params, :no_reroute => true})
            member = model_class.first(:email => email)
            if member.hashed_password.blank?              
              # Problem, stay on registration
              do_view(packet, :register, opts)
            else
              packet.flash("info", "Looks like this email address is already on our members list. Please take the time to correct our details about you.")
              packet.session["member"] = member.id
              packet.reroute(@my_orange_name, :orange, :profile)
            end
          else
            # A person trying to sign up with an email that already
            # has a password
            packet.flash("error", "Looks like this email address already has an account. Try logging in instead.")
            packet.reroute(@my_orange_name, :orange, :login)
          end
        else
          # New member time!
          new(packet, {:no_reroute => true, :params => params})
          # success ?
          member = model_class.first(:email => params["email"])
          if member
            packet.session["member"] = member.id
            packet.flash("info", "You've successfully created an account. Please take the time to fill in more details about yourself.")
            packet.reroute(@my_orange_name, :orange, :profile)
          else
            # Problem, stay on registration
            do_view(packet, :register, opts)
          end
        end # End pre-existing member if 
      else
        do_view(packet, :register, opts)
      end
    end
    
    def logout(packet, opts = {})
      packet.session["member"] = nil
      do_view(packet, :logout, opts)
    end
    
    def profile(packet, opts = {})
      no_reroute = opts.delete(:no_reroute)
      # login check
      unless packet.session["member"]
        packet.flash("error", "You must log in to view this page")
        packet.reroute(@my_orange_name, :orange, :login) 
      end
      
      if packet.request.post?
        params = packet.request.params["members"]
        if params["current_password"].blank?
          # Can't change password without confirming current
          params.delete("password")
          params.delete("repeat_password")
          password_change = false
        else 
          password_change = true
        end
        member = model_class.get(packet.session["member"])
        check = model_class.new(:password => params.delete("current_password"))
        if !password_change || member.hashed_password == check.hashed_password
          save(packet, {:resource_id => packet.session["member"], :no_reroute => true, :params => params})
        else
          packet.flash("error", "Your old password was not input correctly")
        end
      end
      member = model_class.get(packet.session["member"])
      opts[:model] = member
      do_view(packet, :profile, opts)
    end
    
    
    def beforeNew(packet, params)
      unless params["password"] == params["repeat_password"]
        packet.flash("error", "New password does not match repeated password")
        return false 
      end
      unless params["password"].blank? || params["password"].size >= 6
        packet.flash("error", "Password should be over 6 characters")
        return false
      end
      params.delete("password") if params["password"].blank?
      params.delete("repeat_password")
      true
    end
    
    def beforeSave(packet, m, params)
      unless params["password"] == params["repeat_password"]
        packet.flash("error", "New password does not match repeated password")
        return false 
      end
      unless params["password"].blank? || params["password"].size >= 6
        packet.flash("error", "Password should be over 6 characters")
        return false
      end
      params.delete("password") if params["password"].blank?
      params.delete("repeat_password")
      true
    end
  end
end