require 'orange-core/middleware/base'



module Orange::Middleware
  # This middleware locks down entire contexts and puts them behind an openid 
  # login system. Currently only supports a single user id. 
  #
  # 
  class AccessControl < Base
    # Sets up the options for the middleware
    # @param [Hash] opts hash of options
    # @option opts [Boolean] :openid Whether to use openid logins or not (currently only option)
    # @option opts [Boolean] :handle_login Whether the access control system should handle 
    #   presenting the login form, or let other parts of the app do that. 
    # @option opts [Boolean] :config_id Whether to use the id set in a config file
    
    def init(opts = {})
      defs = {:locked => [:admin, :orange], :login => '/login', :logout => '/logout',
              :handle_login => true, :openid => true, :single_user => false}
      opts = opts.with_defaults!(defs)
      @openid = opts[:openid]
      @locked = opts[:locked]
      @login = opts[:login]
      @logout = opts[:logout]
      @handle = opts[:handle_login]
      @single = opts[:single_user]
      unless @single
        orange.load(Orange::UserResource.new, :users)
      end
    end
      
    def packet_call(packet)
      packet['user.id'] ||= (packet.session['user.id'] || false)
      packet['user'] = orange[:users].user_for(packet) unless packet['user.id'].blank?
      if @openid && need_to_handle?(packet)
        ret = handle_openid(packet)
        return ret unless ret.blank? # unless handle_openid returns false, exit immediately
      end
      unless access_allowed?(packet)
        packet.session['user.after_login'] = packet.request.path
        packet.reroute(@login)
      end
      
      pass packet
    end
    
    def access_allowed?(packet)
      return true unless @locked.include?(packet['route.context'])
      if packet['user.id'] || packet['orange.globals']['main_user'] == false
        if @single && (packet['user.id'] == packet['orange.globals']['main_user'] )
          true
        elsif @single
          # Current id no good. 
          packet['user.id'] = false
          packet.session['user.id'] = false
          false
        # Main_user can always log in (root access)
        elsif packet['user.id'] == packet['orange.globals']['main_user']
          orange[:users].new(packet, :open_id => packet['user.id'], :name => 'Main User') unless packet['user', false]
          true
        else
          orange[:users].access_allowed?(packet, packet['user.id'])
        end
      else
        false
      end
    end
    
    def need_to_handle?(packet)
      @handle && ([@login, @logout].include? packet.request.path.gsub(/\/$/, ''))
    end
    
    def handle_openid(packet)
      if packet.request.path.gsub(/\/$/, '') == @logout
        packet.session['user.id'] = nil
        packet['user.id'] = nil
        after = packet.session['user.after_login'].blank? ? 
                '/' : packet.session['user.after_login'] 
        packet.reroute(after)
        return false
      end
      packet.reroute('/') if packet['user.id'] # Reroute to index if we're logged in.
      
      # If login set
      if packet.request.post?
        packet['template.disable'] = true
        # Check for openid response
        if resp = packet.env["rack.openid.response"]
          if resp.status == :success
            packet['user.id'] = resp.identity_url
            
            packet['user.openid.url'] = resp.identity_url
            packet['user.openid.response'] = resp
            # Load in any registration data gathered
            profile_data = {}
            # merge the SReg data and the AX data into a single hash of profile data
            [ OpenID::SReg::Response, OpenID::AX::FetchResponse ].each do |data_response|
              if data_response.from_success_response( resp )
                profile_data.merge! data_response.from_success_response( resp ).data
              end
            end
            
            if packet['user.id'] =~ /^https?:\/\/(www.)?google.com\/accounts/
              packet['user.id'] = profile_data["http://axschema.org/contact/email"]
              packet['user.id'] = packet['user.id'].first if packet['user.id'].kind_of?(Array)
            end
            
            if packet['user.id'] =~ /^https?:\/\/(www.)?yahoo.com/
              packet['user.id'] = profile_data["http://axschema.org/contact/email"]
              packet['user.id'] = packet['user.id'].first if packet['user.id'].kind_of?(Array)
            end
            
            
            after = packet.session.has_key?('user.after_login') ?
                        packet.session['user.after_login'] : '/'
            packet.session['user.after_login'] = false
            
            # Save id into session if we have one.
            packet.session['user.id'] = packet['user.id']
            
            # If the user was supposed to be going somewhere, redirect there
            packet.reroute(after)
            false
          else
            packet.session['flash.error'] = resp.status
            packet.reroute(@login)
            false
          end
        # Set WWW-Authenticate header if awaiting openid.response
        else
          packet[:status] = 401
          packet[:headers] = {}
          packet.add_header('WWW-Authenticate', Rack::OpenID.build_header(
                :identifier => packet.request.params["openid_identifier"],
                :required => [:email, "http://axschema.org/contact/email"]
                ) 
          )
          packet[:content] = 'Got openID?'          
          return packet.finish
        end
      # Show login form, if necessary
      else
        packet[:content] = orange[:parser].haml('openid_login.haml', packet)
        return packet.finish
      end
    end # end handle_openid
  end
end