require 'orange/middleware/base'



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
              :handle_login => true, :openid => true, :config_id => true}
      opts = opts.with_defaults!(defs)
      @openid = opts[:openid]
      @locked = opts[:locked]
      @login = opts[:login]
      @logout = opts[:logout]
      @handle = opts[:handle_login]
      @single = opts[:config_id]
    end
      
    def packet_call(packet)
      packet['user.id'] ||= (packet.session['user.id'] || false)
      if @openid && need_to_handle?(packet)
        ret = handle_openid(packet)
        return ret if ret # unless handle_openid returns false, exit immediately
      end
      unless access_allowed?(packet)
        packet.session['user.after_login'] = packet.request.path
        packet.reroute(@login)
      end
      
      pass packet
    end
    
    def access_allowed?(packet)
      return true unless @locked.include?(packet['route.context'])
      if packet['user.id']
        if @single && (packet['user.id'] == packet['orange.globals']['main_user'])
          true
        elsif @single
          # Current id no good. 
          packet['user.id'] = false
          packet.session['user.id'] = false
          false
        else
          true
        end
      else
        false
      end
    end
    
    def need_to_handle?(packet)
      @handle && ([@login, @logout].include? packet.env['REQUEST_PATH'])
    end
    
    def handle_openid(packet)
      if packet.env['REQUEST_PATH'] == @logout
        packet.session['user.id'] = nil
        packet['user.id'] = nil
        after = packet.session['user.after_login'].blank? ? 
                '/' : packet.session['user.after_login'] 
        packet.reroute(after)
        false
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
            raise 'foo'
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
                :identifier => packet.request.params["openid_identifier"]
              ))
          packet[:content] = 'Got openID?'
          packet.finish
        end
      # Show login form, if necessary
      else
        packet[:content] = orange[:parser].haml('openid_login.haml', packet)
        packet.finish
      end
    end # end handle_openid
  end
end