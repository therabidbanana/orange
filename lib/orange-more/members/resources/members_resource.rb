require 'spreedly'
require 'hominid'

module Orange
  class MembersResource < Orange::ModelResource
    use OrangeMember
    call_me :members
    def stack_init
      options[:spreedly_key] = orange.options['spreedly_key'] || false
      options[:spreedly_plan] = orange.options['spreedly_plan'] || false
      options[:spreedly_site] = orange.options['spreedly_site'] || false
      options[:mailchimp_key] = orange.options["mailchimp_key"] || false
      options[:mailchimp_list] = orange.options["mailchimp_list"] || false
      options[:mailchimp_interests] = orange.options["mailchimp_interests"] || false
      options[:mailchimp_merge_fields] = orange.options["mailchimp_merge_fields"] || {}
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
    
    def hominid
      @hominid ||= Hominid::Base.new({:api_key => options[:mailchimp_key]}) if options[:mailchimp_key]
    end
    
    def hominid_list
      @hominid_list ||= hominid.find_list_by_id(options[:mailchimp_list]) if options[:mailchimp_list] && hominid
    end
    
    
    
    def paid?(packet, member)
      return true unless options[:spreedly_key]
      unless member.is_a? model_class
        member = model_class.get(member)
      end
      subscriber = Spreedly::Subscriber.find(member.id)
      subscriber ? subscriber.active? : false
    end
    
    def subscription_url(packet, member)
      return "" unless options[:spreedly_key]
      unless member.is_a? model_class
        member = model_class.get(member)
      end
      Spreedly.subscribe_url(member.id, options[:spreedly_plan])
    end
    
    def list_groups(packet)
      hominid.call("listInterestGroupings", options[:mailchimp_list]).select{|g| options[:mailchimp_interests].include? g["name"]}
    end
    
    def list_groups_for_email(packet, email)
      chimp_info = hominid.member_info(options[:mailchimp_list], email)
    end
        # 
        # def add_to_mailchimp(packet, member_params)
        #   email = member_params[:email]
        #   fname = member_params[:first_name]
        #   lname = member_params[:last_name]
        #   interests = member_params[:groups].map{|key, val| 
        #     { "name" => key, "groups" => groups.map{|str| str.gsub(/,/, "\,")}.join(",") }
        #   }
        #   hominid.subscribe(options[:mailchimp_list], email, {:FNAME => fname, :LNAME => lname, :INTERESTS => interests}, {:update_existing => true})
        # end
    
    def synchronize_with_mailchimp(packet, member_params)
      email = member_params["email"]
      old_email = member_params["old_email"] || email
      fname = member_params["first_name"] || ''
      lname = member_params["last_name"] || ''
      others = {}
      for key, val in options[:mailchimp_merge_fields]
        others[val.upcase.to_sym] = member_params[key] || ''
      end
      interests = member_params["groups"].blank? ? [] : member_params["groups"].map{|key, val| 
        { "name" => key, "groups" => val.reject{|str| str.blank? }.map{|str| str.gsub(/,/, '\,')}.join(",") }
      }
      hominid.subscribe(options[:mailchimp_list], old_email, {:FNAME => fname, :LNAME => lname, :GROUPINGS => interests}.merge(others), {:update_existing => true})
    end
    
    def synchronize_from_mailchimp(packet, member)
      email = member.email
      member_info = mailchimp_member_info(packet, member)
      for key, val in options[:mailchimp_merge_fields]
        member.attribute_set(key, member_info["merges"][val])
      end
      member.save
    end
    
    def batch_update_interest_mailchimp(packet, emails, grouping_name, groups)
      interests = [{ "name" => grouping_name, "groups" => groups }]
      emails = emails.map{|e| {:EMAIL => e, :GROUPINGS => interests}}
      hominid.subscribe_many(options[:mailchimp_list], emails, {:double_opt_in => true, :update_existing => true, :replace_interests => false})
    end
    
    def add_attendee_group(packet, grouping_name, name, limit = 15)
      list = options[:mailchimp_list]
      my_groups = hominid.call("listInterestGroupings", list)
      grouping = my_groups.select{|a| a["name"] == grouping_name}.first
      if grouping
        # Return true if already in the list.
        return true if grouping["groups"].select{|a| a["name"] == name }.size > 0
      
        # Keep group size manageable
        if grouping["groups"].size > limit
          remove = grouping["groups"].shift 
          hominid.call("listInterestGroupDel", list, remove["name"], grouping["id"])
        end
        hominid.call("listInterestGroupAdd", list, name, grouping["id"])
      else
        hominid.call("listInterestGroupingAdd", list, grouping_name, "checkboxes", [name] )
      end
    end
    
    def unsubscribe_from_mailchimp(packet, email)
      hominid.unsubscribe(options[:mailchimp_list], email)
    end
    
    def mailchimp_member_info(packet, member)
      # Can give member id, hydrate to member before continuing.
      unless member.is_a? model_class
        member = model_class.get(member)
      end
      return [] unless member && options[:mailchimp_list]
      list = options[:mailchimp_list]
      begin
        mailchimp_info = hominid.member_info(list, member.email)
      rescue Hominid::ListError => e
        mailchimp_info = {}
      end
      mailchimp_info
    end
    
    def login(packet, opts = {})
      if packet.request.post?
        params = packet.request.params["members"]
        login = params["login_email"]
        password = params["login_password"]
        member = model_class.first({:email => login})
        tester = model_class.new({:salt => (member.salt || "")})
        tester.password = password
        if member && tester.hashed_password == member.hashed_password
          packet.session["member"] = member.id
          packet.reroute(@my_orange_name, :orange, :profile)
        else
          packet.flash("error", "Invalid email or password")
          do_view(packet, :login, opts)
        end
      else
        packet.reroute(@my_orange_name, :orange, :profile) if packet.session["member"]
        do_view(packet, :login, opts)
      end
    end
    
    def register(packet, opts = {})
      if packet.request.post?
        params = packet.request.params["members"]
        unless params["name"].blank?
          # Problem, stay on registration
          packet.flash("error", "It looks like you might be a spam robot. Make sure you didn't fill out an extra field by mistake.")
          return do_view(packet, :register, opts.merge(:list_groups => list_groups(packet)))
        end
        params.delete("name")
        member = model_class.first(:email => params["email"])
        if member
          # Existing member... do they already have password?
          if member.hashed_password.blank?
            # A member who is part of the mailing list, but hasn't
            # set a password
            email = params.delete("email")
            mailing_list = params.delete("email_subscribe")
            groups = params.delete("groups")
            save(packet, {:resource_id => member.id, :params => params, :no_reroute => true})
            member = model_class.first(:email => email)
            if member.hashed_password.blank?              
              # Problem, stay on registration
              do_view(packet, :register, opts.merge(:list_groups => list_groups(packet)))
            else
              packet.flash("info", "Looks like this email address was already on our mailing list. Please take the time to correct our details about you.")
              packet.session["member"] = member.id
              # Synchronize with the mailchimp account.
              params.merge!("groups" => groups)
              synchronize_with_mailchimp(packet, params.merge("groups" => groups, "email" => email)) if mailing_list
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
          mailing_list = params.delete("email_subscribe")
          groups = params.delete("groups")
          new(packet, {:no_reroute => true, :params => params})
          # success ?
          member = model_class.first(:email => params["email"])
          if member && !(mailchimp_member_info(packet, member).blank?)
            packet.session["member"] = member.id
            synchronize_from_mailchimp(packet, member)
            synchronize_with_mailchimp(packet, params.merge("groups" => groups)) if mailing_list
            packet.flash("info", "Looks like this email address was already on our mailing list. Please take the time to correct our details about you.")
            packet.reroute(@my_orange_name, :orange, :profile)
          elsif member
            packet.session["member"] = member.id
            params.merge!("groups" => groups)
            synchronize_with_mailchimp(packet, params.merge("groups" => groups)) if mailing_list
            packet.flash("info", "You've successfully created an account. Please take the time to fill in more details about yourself.")
            packet.reroute(@my_orange_name, :orange, :profile)
          else
            # Problem, stay on registration
            do_view(packet, :register, opts.merge(:list_groups => list_groups(packet)))
          end
        end # End pre-existing member if 
      else
        do_view(packet, :register, opts.merge(:list_groups => list_groups(packet)))
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
          
          mailing_list = params.delete("email_subscribe")
          groups = params.delete("groups")
          old_email = member.email
          save(packet, {:resource_id => packet.session["member"], :no_reroute => true, :params => params})
          if mailing_list == "1"
            synchronize_with_mailchimp(packet, params.merge("groups" => groups, "old_email" => old_email))
          else
            unsubscribe_from_mailchimp(packet, params["email"])
          end
        else
          packet.flash("error", "Your old password was not input correctly")
        end
      end
      member = model_class.get(packet.session["member"])
      opts[:model] = member
      do_view(packet, :profile, opts.merge(:list_groups => list_groups(packet)))
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